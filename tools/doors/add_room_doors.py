from pathlib import Path
import re,math,json
ROOT=Path(__file__).resolve().parents[2];p=ROOT/'scenes/levels/ThirtyLevel.tscn';s=p.read_text(encoding='utf-8');res={m[1]:m[0] for m in re.finditer(r'\[sub_resource[^\n]*id="([^"]+)"\].*?(?=\n\[|\Z)',s,re.S)};blocks=re.findall(r'\[node [^\n]+\].*?(?=\n\[|\Z)',s,re.S)
Path(ROOT/'scenes/interactables/doors/RoomDoor.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="PackedScene" path="res://scenes/interactables/doors/SecretDoor.tscn" id="1"]\n[node name="RoomDoor" instance=ExtResource("1")]\nrequired_item = &""\nconsume_required_item = false\n',encoding='utf-8')
overrides={'SalaProfessor01':(0,-4.8,35.5,36.5),'SalaAbandonadaNorte':(2,80.3,5.966667,6.933334),'SalaSecreta2':(0,27.175,88.88889,89.79444)}
report=[]
for b in blocks:
 h=b.splitlines()[0]
 if 'parent="."' not in h or not any(t in h for t in ('Sala','Laboratorio','Banheiro','Secretaria','Achados')):continue
 name=re.search('name="([^"]+)"',h)[1]
 if any('parent="'+name+'"' in q.splitlines()[0] and ('name="Door"' in q.splitlines()[0] or 'name="RoomDoor"' in q.splitlines()[0]) for q in blocks):continue
 md=re.search(r'mesh_data = SubResource\("([^"]+)"',b)
 if not md:continue
 data=res[md[1]];a=list(map(float,re.search(r'positions = PackedVector3Array\(([^)]+)',data)[1].split(',')));pos=list(zip(a[::3],a[1::3],a[2::3]));lo=[min(v[i] for v in pos) for i in range(3)];hi=[max(v[i] for v in pos) for i in range(3)];gaps=[]
 for axis in (0,2):
  along=2-axis
  for fixed in (lo[axis],hi[axis]):
   spans=[]
   for fid in re.findall(r'SubResource\("([^"]+)"\)',data):
    ids=re.search(r'vertices = PackedInt32Array\(([^)]+)',res[fid])[1];vs=[pos[int(i)] for i in ids.split(',')]
    if any(abs(v[axis]-fixed)>.01 for v in vs):continue
    hits=[]
    for j,v in enumerate(vs):
     q=vs[j-1]
     if (v[1]>1)!=(q[1]>1):hits.append(v[along]+(q[along]-v[along])*(1-v[1])/(q[1]-v[1]))
    hits.sort();spans.extend(zip(hits[::2],hits[1::2]))
   end=lo[along]
   for start,stop in sorted(spans):
    if .72<start-end<1.6:gaps.append((axis,fixed,end,start))
    end=max(end,stop)
   if .72<hi[along]-end<1.6:gaps.append((axis,fixed,end,hi[along]))
 if name in overrides:gaps=[overrides[name]]
 if not gaps:raise RuntimeError('No doorway: '+name)
 # Prefer the established corridor entrance for the irregular northern bathroom.
 if name=='BanheiroMasculinoNorte':gaps=[max(gaps,key=lambda g:g[2])]
 axis,fixed,start,end=gaps[0];low=abs(fixed-lo[axis])<abs(fixed-hi[axis]);width=end-start
 if axis==0:
  yaw=math.pi/2 if low else -math.pi/2;origin=(fixed,0,end if low else start)
 else:
  yaw=0 if low else math.pi;origin=(start if low else end,0,fixed)
 s+=f'\n[node name="RoomDoor" parent="{name}" instance=ExtResource("room_door_unlocked")]\nposition = Vector3({origin[0]}, 0, {origin[2]})\nrotation = Vector3(0, {yaw}, 0)\nscale = Vector3({width}, 1, 1)\n'
 report.append({'room':name,'width':width,'axis':axis,'position':origin})
if 'id="room_door_unlocked"' not in s:
 at=s.index('[sub_resource');s=s[:at]+'[ext_resource type="PackedScene" path="res://scenes/interactables/doors/RoomDoor.tscn" id="room_door_unlocked"]\n\n'+s[at:]
p.write_text(s,encoding='utf-8');(ROOT/'tools/doors/room_doors_manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print('Added',len(report),'unlocked doors')
