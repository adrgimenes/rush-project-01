from pathlib import Path
import re,math,json
ROOT=Path(__file__).resolve().parents[2]; scene=ROOT/'scenes/levels/ThirtyLevel.tscn'; s=scene.read_text(encoding='utf-8')
res={m[1]:m[0] for m in re.finditer(r'\[sub_resource[^\n]*id="([^"]+)"\].*?(?=\n\[|\Z)',s,re.S)}
b=re.search(r'\[node name="Level"[^\n]*\].*?(?=\n\[)',s,re.S)[0];data=res[re.search(r'mesh_data = SubResource\("([^"]+)"',b)[1]]
a=list(map(float,re.search(r'positions = PackedVector3Array\(([^)]+)',data)[1].split(',')));points=list(zip(a[::3],a[1::3],a[2::3]));faces=[];floors=[]
for fid in re.findall(r'SubResource\("([^"]+)"\)',data):
 m=re.search(r'vertices = PackedInt32Array\(([^)]+)',res[fid])
 if not m:continue
 vs=[points[int(i)] for i in m[1].split(',')];faces.append(vs)
 if max(v[1] for v in vs)<.02: floors.append([(v[0],v[2]) for v in vs])
def inside(x,z):
 for poly in floors:
  hit=False
  for i,(a,b) in enumerate(poly):
   c,d=poly[i-1]
   if (b>z)!=(d>z) and x<(c-a)*(z-b)/(d-b)+a:hit=not hit
  if hit:return True
 return False
# Merge coplanar contiguous wall segments only at the required mounting height.
def walls(y0,y1):
 groups={}
 for vs in faces:
  lo=[min(v[i] for v in vs) for i in range(3)];hi=[max(v[i] for v in vs) for i in range(3)]
  if lo[1]>y0+.001 or hi[1]<y1-.001:continue
  axis=0 if hi[0]-lo[0]<.001 else 2 if hi[2]-lo[2]<.001 else -1
  if axis<0:continue
  along=2-axis; start,end=lo[along],hi[along]
  if end-start<.25:continue
  fixed=lo[axis];mid=(start+end)/2
  def point(sign):return (fixed+sign*.35,mid) if axis==0 else (mid,fixed+sign*.35)
  sides=[k for k in (-1,1) if inside(*point(k))]
  if len(sides)!=1:continue
  groups.setdefault((axis,round(fixed,3),sides[0]),[]).append((start,end))
 merged=[]
 for key,intervals in groups.items():
  spans=[]
  for start,end in sorted(intervals):
   if spans and start<=spans[-1][1]+.015:spans[-1][1]=max(end,spans[-1][1])
   else:spans.append([start,end])
  merged.extend((key,start,end) for start,end in spans)
 return merged
r=[];n=['[node name="CorridorIndustrialDecor" type="Node3D"]'];i=0;counts={'pipe_runs':0,'extinguishers':0,'graduation_frames':0}
def v(a):return 'Vector3('+','.join(str(round(x,5)) for x in a)+')'
for name,c in {'Steel':(.22,.25,.24),'Pipe':(.28,.30,.27),'Red':(.48,.035,.02),'Black':(.025,.029,.027),'Cream':(.76,.72,.57),'Gold':(.43,.32,.12),'Wood':(.14,.08,.045),'Skin':(.48,.33,.23)}.items():
 r.append(f'[sub_resource type="StandardMaterial3D" id="{name}"]\nalbedo_color = Color({c[0]},{c[1]},{c[2]},1)\nroughness = 0.78'+ ('\nmetallic = 0.6' if name in ('Steel','Pipe','Gold') else ''))
def group(name,key,t,y):
 global i
 i+=1;g=name+str(i);axis,fixed,sign=key
 pos=(fixed,y,t) if axis==0 else (t,y,fixed)
 rot=sign*math.pi/2 if axis==0 else (0 if sign==1 else math.pi)
 n.append(f'[node name="{g}" type="Node3D" parent="."]\nposition = {v(pos)}\nrotation = Vector3(0,{rot},0)');return g
# All props face local +Z, towards the corridor.
def mesh(g,name,pos,size,mat,kind='Box',rot=(0,0,0)):
 global i
 i+=1;key='M'+str(i)
 shape='size = '+v(size) if kind=='Box' else f'top_radius = {size[0]}\nbottom_radius = {size[0]}\nheight = {size[1]}\nradial_segments = 10'
 r.append(f'[sub_resource type="{kind}Mesh" id="{key}"]\n{shape}\nmaterial = SubResource("{mat}")')
 n.append(f'[node name="{name}{i}" type="MeshInstance3D" parent="{g}"]\nposition = {v(pos)}\nrotation = {v(rot)}\nmesh = SubResource("{key}")')
def text(g,name,txt,pos,size=22,color='Color(0.17,0.13,0.08,1)'):
 n.append(f'[node name="{name}" type="Label3D" parent="{g}"]\nposition = {v(pos)}\ntext = "{txt}"\nfont_size = {size}\npixel_size = 0.0025\nmodulate = {color}')
for key,start,end in walls(3.45,3.8):
 if end-start<2.5:continue
 length=end-start-.6;g=group('Tubulacao',key,(start+end)/2,3.65)
 for off,radius,mat in ((.25,.065,'Pipe'),(.48,.045,'Red')):
  mesh(g,'Cano',(0,0,off),(radius,length,0),mat,'Cylinder',(0,0,math.pi/2))
  for j in range(max(2,int(length/2.5)+1)):
   x=-length/2+j*length/max(1,int(length/2.5))
   mesh(g,'Luva',(x,0,off),(radius+.018,.10,0),'Steel','Cylinder',(0,0,math.pi/2))
 for j in range(int(length/3)+1):
  x=-length/2+.15+j*3
  mesh(g,'Suporte',(x,.09,.32),(.05,.04,.68),'Steel')
  mesh(g,'Tirante',(x,.19,.56),(.025,.28,.025),'Steel')
 counts['pipe_runs']+=1
placed=[]
for key,start,end in walls(1.25,2.45):
 if end-start<1.8:continue
 axis,fixed,sign=key
 for t in [start+.9+j*7 for j in range(max(1,int((end-start-1.8)/7)+1))]:
  x,z=(fixed,t) if axis==0 else (t,fixed)
  if any(math.hypot(x-a,z-b)<4.0 for a,b in placed):continue
  placed.append((x,z)); ext=len(placed)%3==1
  if ext:
   g=group('Extintor',key,t,1.35)
   mesh(g,'SuporteParede',(0,-.04,.035),(.16,.55,.05),'Steel')
   mesh(g,'Cilindro',(0,-.05,.16),(.105,.48,0),'Red','Cylinder')
   mesh(g,'Valvula',(0,.22,.16),(.04,.09,0),'Steel','Cylinder')
   mesh(g,'Alavanca',(.02,.28,.16),(.18,.025,.045),'Black')
   mesh(g,'Mangueira',(.13,.04,.17),(.022,.36,0),'Black','Cylinder')
   mesh(g,'Rotulo',(0,-.03,.268),(.14,.18,.012),'Cream')
   text(g,'Tipo','ABC',(0,-.03,.28),19)
   mesh(g,'Placa',(0,.61,.025),(.32,.35,.025),'Red')
   text(g,'Sinal','EXTINTOR\\n\\nv',(0,.61,.044),15,'Color(0.95,0.92,0.8,1)')
   counts['extinguishers']+=1
  else:
   g=group('QuadroFormatura',key,t,1.92)
   mesh(g,'Moldura',(0,0,.04),(1.25,.82,.075),'Wood')
   mesh(g,'Friso',(0,0,.084),(1.17,.74,.014),'Gold')
   mesh(g,'Fundo',(0,0,.096),(1.12,.69,.012),'Cream')
   text(g,'Curso','CIENCIA DA COMPUTACAO',(0,.265,.112),18)
   text(g,'Turma','TURMA '+str(1996+counts['graduation_frames']%12),(0,-.275,.112),18)
   for row in range(2):
    for col in range(6):
     px=-.46+col*.184;py=.10-row*.205
     mesh(g,'Retrato',(px,py,.111),(.145,.175,.008),'Gold')
     mesh(g,'Beca',(px,py-.04,.122),(.095,.075,.008),'Black')
     mesh(g,'Rosto',(px,py+.015,.124),(.048,.057,.01),'Skin')
     mesh(g,'Capelo',(px,py+.052,.13),(.085,.018,.012),'Black')
   counts['graduation_frames']+=1
out=ROOT/'scenes/props/furniture/CorridorIndustrialDecor.tscn';out.write_text('[gd_scene format=3]\n\n'+'\n\n'.join(r+n)+'\n',encoding='utf-8')
if 'id="corridor_industrial_decor"' not in s:
 at=s.index('[sub_resource');s=s[:at]+'[ext_resource type="PackedScene" path="res://scenes/props/furniture/CorridorIndustrialDecor.tscn" id="corridor_industrial_decor"]\n\n'+s[at:]
 s+='\n[node name="DecorCorredores" parent="Level" instance=ExtResource("corridor_industrial_decor")]\n'
 scene.write_text(s,encoding='utf-8')
print(counts)
