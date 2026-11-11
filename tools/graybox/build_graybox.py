import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCALE = 1.0
from level_layout import rooms, corridors, stairs

out=['[gd_scene load_steps=6 format=3]']
for i,c in enumerate([.42,.58,.32,.26,.08],1):
 out += [f'[sub_resource type="StandardMaterial3D" id="Mat{i}"]',f'albedo_color = Color({c}, {c}, {c}, 1)','roughness = 1.0']
out += ['[node name="MainLevel" type="Node3D"]']
count=0
def node(name,parent,typ='Node3D',props=()):
 out.extend([f'[node name="{name}" type="{typ}" parent="{parent}"]',*props])
def box(parent,name,x,y,z,w,h,d,mat=2,collision=True):
 global count
 count+=1
 mesh=f'Mesh{count}'; shape=f'Shape{count}'
 # Inline resources are inserted before the first node when writing.
 resources.extend([f'[sub_resource type="BoxMesh" id="{mesh}"]',f'size = Vector3({w}, {h}, {d})'])
 node(name,parent,'MeshInstance3D',[f'position = Vector3({x}, {y}, {z})',f'mesh = SubResource("{mesh}")',f'material_override = SubResource("Mat{mat}")'])
 if collision:
  resources.extend([f'[sub_resource type="BoxShape3D" id="{shape}"]',f'size = Vector3({w}, {h}, {d})'])
  node('Body',parent+'/'+name,'StaticBody3D');node('Collision',parent+'/'+name+'/Body','CollisionShape3D',[f'shape = SubResource("{shape}")'])
resources=[]
node('Rooms','.');node('Corridors','.');node('Doors','.');node('Structure','.');node('Stairs','.')
rects=[r[1:5] for r in rooms]+corridors
for r in rooms:
 name,x1,z1,x2,z2,side,p=r;node(name,'Rooms')
 # The inner room is carved out of its surrounding room below.
# A single planar partition prevents overlapping floors at intersections.
rects += stairs
xs = sorted(set(v for r in rects for v in (r[0], r[2])))
zs = sorted(set(v for r in rects for v in (r[1], r[3])))
def owner(x, z):
 for i, (a, b, c, d) in enumerate(rects[:len(rooms)]):
  if a < x < c and b < z < d: return i
 if any(a < x < c and b < z < d for a,b,c,d in corridors): return -1
 if any(a < x < c and b < z < d for a,b,c,d in stairs): return -2
 return None
for a,c in zip(xs,xs[1:]):
 for b,d in zip(zs,zs[1:]):
  region = owner((a+c)/2,(b+d)/2)
  if region is None: continue
  parent = 'Rooms/'+rooms[region][0] if region >= 0 else 'Stairs' if region == -2 else 'Corridors'
  for label,y,mat in [('Floor',-.1,1),('Ceiling',4.1,3)]:
   box(parent,f'{label}_{count}',(a+c)/2,y,(b+d)/2,c-a,.2,d-b,mat)
doors=[]
for i,r in enumerate(rooms):
 name,a,b,c,d,s,p=r
 if s:doors.append((s in ('N','S'), b if s=='N' else d if s=='S' else a if s=='W' else c,p,i))
def wall(horizontal,fixed,start,end,left,right):
 if left==right:return
 if set((left,right)) == {-1,-2}: return
 cuts=[start,end]
 matches=[q for q in doors if q[0]==horizontal and q[1]==fixed and q[3] in (left,right)]
 for _,_,p,_ in matches:cuts.extend([max(start,min(end,p-.6)),max(start,min(end,p+.6))])
 cuts=sorted(set(cuts))
 for a,b in zip(cuts,cuts[1:]):
  mid=(a+b)/2; opening=any(abs(mid-q[2])<.6 for q in matches)
  h=1.6 if opening else 4; y=3.2 if opening else 2
  x,z=(mid,fixed) if horizontal else (fixed,mid)
  box('Structure',f'Wall_{count}',x*SCALE,y,z*SCALE,(b-a)*SCALE if horizontal else .12,h,.12 if horizontal else (b-a)*SCALE)
for x in xs:
 for a,b in zip(zs,zs[1:]):wall(False,x,a,b,owner(x-.001,(a+b)/2),owner(x+.001,(a+b)/2))
for z in zs:
 for a,b in zip(xs,xs[1:]):wall(True,z,a,b,owner((a+b)/2,z-.001),owner((a+b)/2,z+.001))
for horizontal,fixed,p,i in doors:
 name=rooms[i][0];parent='Doors/'+name;node(name,'Doors')
 x,z=(p-.55,fixed) if horizontal else (fixed,p-.55)
 node('Pivot',parent,'Node3D',[f'position = Vector3({x*SCALE}, 0, {z*SCALE})'])
 box(parent+'/Pivot','Leaf',.495 if horizontal else 0,1.17,0 if horizontal else .495,.99 if horizontal else .07,2.34,.07 if horizontal else .99,4)
 for offset in [-.58,.58]:
  x,z=(p+offset,fixed) if horizontal else (fixed,p+offset)
  box(parent,'Frame_'+str(offset).replace('.','_'),x*SCALE,1.2,z*SCALE,.06 if horizontal else .18,2.4,.18 if horizontal else .06,4)
for flight,(a,b,c,d) in enumerate(stairs):
 for i in range(12):
  height = (i+1)*.16
  box('Stairs',f'Step_{flight}_{i}',c-(i+.5)*.5,height/2,(b+d)/2,.5,height,d-b-.12,3)
 for i in range(8):
  rid=f'Fade{flight}_{i}'
  resources.extend([f'[sub_resource type="StandardMaterial3D" id="{rid}"]','transparency = 1','shading_mode = 0','cull_mode = 2',f'albedo_color = Color(0, 0, 0, {0.12+i*.1})'])
  box('Stairs',f'Darkness_{flight}_{i}',c-1-i*.65,2,(b+d)/2,.01,4,d-b-.12,5,False)
  out[-1]=f'material_override = SubResource("{rid}")'
 node(f'Barrier{flight}','Stairs','StaticBody3D')
 resources.extend([f'[sub_resource type="BoxShape3D" id="BarrierShape{flight}"]',f'size = Vector3(0.12, 4, {d-b})'])
 node('Collision',f'Stairs/Barrier{flight}','CollisionShape3D',[f'position = Vector3({c-.15}, 2, {(b+d)/2})',f'shape = SubResource("BarrierShape{flight}")'])
first=next(i for i,s in enumerate(out) if s.startswith('[node'))
out[first:first]=resources
out[0]='[gd_scene format=3]'
(ROOT/'scenes/levels').mkdir(parents=True, exist_ok=True)
(ROOT/'scenes/levels/MainLevel.tscn').write_text('\n\n'.join(out)+'\n',encoding='utf-8')
print(f'Generated {len(rooms)} rooms, {len(doors)} doors, {count} meshes')

