"""Generate room-specific editable low-poly props. Existing Decor and mission props are preserved."""
from pathlib import Path
import re, json, math, unicodedata
ROOT=Path(__file__).resolve().parents[2]
SCENE=ROOT/'scenes/levels/ThirtyLevel.tscn'
OUT=ROOT/'scenes/props/furniture/rooms'
OUT.mkdir(parents=True,exist_ok=True)
s=SCENE.read_text(encoding='utf-8')
blocks=re.findall(r'\[node [^\n]+\].*?(?=\n\[|\Z)',s,re.S)
def slug(t): return re.sub('[^a-zA-Z0-9]+','_',unicodedata.normalize('NFKD',t).encode('ascii','ignore').decode()).strip('_')
def vec(v): return 'Vector3('+','.join(str(round(x,5)) for x in v)+')'
PALETTE={'Wood':(.25,.17,.10),'Steel':(.18,.23,.22),'Paper':(.72,.67,.51),'Dark':(.035,.043,.041),'Blue':(.12,.21,.26),'Red':(.30,.09,.055),'Green':(.08,.15,.12),'Ceramic':(.65,.66,.58),'Glass':(.12,.21,.21),'Grime':(.15,.14,.09)}
class Decor:
 def __init__(self,name,w,d,h):
  self.name=name; self.w=w; self.d=d; self.h=h; self.res=[]; self.nodes=['[node name="RoomDecor" type="Node3D"]']; self.i=0; self.occupied=[]; self.missions=[]; self.count=0
  for k,c in PALETTE.items(): self.res.append(f'[sub_resource type="StandardMaterial3D" id="{k}"]\nalbedo_color = Color({c[0]},{c[1]},{c[2]},1)\nroughness = 0.88'+ ('\nmetallic = 0.65' if k=='Steel' else ''))
 def group(self,name,x,z):
  self.i+=1; key=name+str(self.i); self.nodes.append(f'[node name="{key}" type="Node3D" parent="."]\nposition = {vec((x,0,z))}'); return key
 def mesh(self,name,pos,size,mat='Wood',parent='.',solid=False,kind='Box',rot=(0,0,0)):
  self.i+=1; key='R'+str(self.i); node=name+str(self.i); self.count+=1
  desc=f'size = {vec(size)}' if kind=='Box' else f'top_radius = {size[0]}\nbottom_radius = {size[0]}\nheight = {size[1]}\nradial_segments = 10'
  self.res.append(f'[sub_resource type="{kind}Mesh" id="{key}"]\n{desc}\nmaterial = SubResource("{mat}")')
  self.nodes.append(f'[node name="{node}" type="MeshInstance3D" parent="{parent}"]\nposition = {vec(pos)}\nrotation = {vec(rot)}\nmesh = SubResource("{key}")')
  if solid:
   sz=size if kind=='Box' else (size[0]*2,size[1],size[0]*2)
   self.res.append(f'[sub_resource type="BoxShape3D" id="S{key}"]\nsize = {vec(sz)}')
   path=node if parent=='.' else parent+'/'+node
   self.nodes.append(f'[node name="Body" type="StaticBody3D" parent="{path}"]\n[node name="Collision" type="CollisionShape3D" parent="{path}/Body"]\nshape = SubResource("S{key}")')
 def label(self,text,pos,parent='.',size=22,rot=0):
  self.i+=1; self.nodes.append(f'[node name="Texto{self.i}" type="Label3D" parent="{parent}"]\nposition = {vec(pos)}\nrotation = Vector3(0,{rot},0)\ntext = "{text}"\nfont_size = {size}\npixel_size = 0.004\nmodulate = Color(0.25,0.23,0.18,1)')
 def reserve(self,x,z,w,d):
  # Continuous perimeter lane remains clear, including all wall entrances.
  if x-w/2<.85 or x+w/2>self.w-.85 or z-d/2<.85 or z+d/2>self.d-.85: return False
  if any(abs(x-a)<(w+c)/2+.15 and abs(z-b)<(d+e)/2+.15 for a,b,c,e in self.occupied): return False
  if any(math.hypot(x-a,z-b)<1.65+max(w,d)/2 for a,b in self.missions): return False
  self.occupied.append((x,z,w,d)); return True
 def chair(self,p,x,z):
  self.mesh('Assento',(x,.45,z),(.43,.07,.43),'Blue',p,True)
  self.mesh('Encosto',(x,.77,z+.21),(.43,.52,.055),'Blue',p,True)
  for dx in (-.16,.16):
   for dz in (-.16,.16): self.mesh('PeCadeira',(x+dx,.21,z+dz),(.035,.42,.035),'Steel',p)
 def desk(self,x,z,computer=False):
  if not self.reserve(x,z,1.15,1.40): return
  p=self.group('PostoComputador' if computer else 'Carteira',x,z)
  self.mesh('Tampo',(0,.76,-.22),(1.10,.07,.59),'Wood',p,True)
  for dx in (-.46,.46): self.mesh('Estrutura',(dx,.36,-.22),(.055,.72,.48),'Steel',p,True)
  self.chair(p,0,.38)
  if computer:
   self.mesh('BaseMonitor',(0,.82,-.30),(.34,.04,.23),'Dark',p)
   self.mesh('Monitor',(0,1.07,-.35),(.51,.39,.19),'Steel',p)
   self.mesh('Tela',(0,1.07,-.248),(.43,.30,.012),'Glass',p)
   self.mesh('Teclado',(0,.815,-.04),(.45,.025,.14),'Ceramic',p)
   for j in range(3): self.mesh('Teclas',(0,.833,-.09+j*.045),(.39,.006,.018),'Dark',p)
   self.mesh('Mouse',(.38,.82,-.07),(.07,.035,.10),'Dark',p)
   self.mesh('Gabinete',(.36,.35,-.25),(.23,.66,.40),'Dark',p,True)
  else:
   self.mesh('Caderno',(0,.805,-.25),(.25,.022,.33),'Paper',p)
   self.mesh('Lapis',(.23,.81,-.23),(.015,.015,.20),'Red',p)
 def shelf(self,x,z,theme='files'):
  if not self.reserve(x,z,1,.5): return
  p=self.group('Estante',x,z)
  for dx in (-.45,.45): self.mesh('Lateral',(dx,.9,0),(.06,1.8,.44),'Steel',p,True)
  for j,y in enumerate((.15,.68,1.21,1.74)):
   self.mesh('Prateleira',(0,y,0),(1,.045,.48),'Wood',p,True)
   for k in range(3):
    if theme=='files':
     self.mesh('Pasta',(-.31+k*.29,y+.19,0),(.20,.33,.29),'Blue' if k%2 else 'Red',p)
     self.mesh('Etiqueta',(-.31+k*.29,y+.19,.15),(.11,.10,.009),'Paper',p)
    else:
     self.mesh('Caixa',(-.31+k*.29,y+.16,0),(.25,.27,.32),'Wood',p)
     self.mesh('Fita',(-.31+k*.29,y+.30,0),(.04,.01,.32),'Paper',p)
 def board(self,title,notes):
  y=min(2.5,self.h-.45)
  self.mesh('QuadroMoldura',(self.w/2,y,.065),(min(2.5,self.w-.5),.72,.10),'Wood',solid=True)
  self.mesh('QuadroInterior',(self.w/2,y,.123),(min(2.36,self.w-.65),.60,.015),'Paper')
  self.label(title+'\\n\\n'+notes,(self.w/2,y,.14),size=20)
 def common(self):
  # Surface details do not obstruct routes; no independent lights bypass PowerState.
  for j in range(3):
   self.mesh('PapelCaido',(self.w*.4+j*.21,.008,self.d*.6),(.19,.008,.25),'Paper',rot=(0,j*.4,0))
  self.mesh('Luminaria',(self.w/2,self.h-.18,self.d/2),(min(1.2,self.w*.5),.09,.25),'Steel')
  self.mesh('DifusorApagado',(self.w/2,self.h-.23,self.d/2),(min(1.1,self.w*.45),.015,.18),'Ceramic')
 def toilet(self,x,z):
  if not self.reserve(x,z,1.15,1.5): return
  p=self.group('CabineSanitaria',x,z)
  self.mesh('Tanque',(0,.78,-.39),(.48,.53,.23),'Ceramic',p,True)
  self.mesh('Base',(0,.20,0),(.29,.40,.35),'Ceramic',p,True)
  self.mesh('Vaso',(0,.43,0),(.25,.18,0),'Ceramic',p,True,'Cylinder')
  self.mesh('InteriorVaso',(0,.525,0),(.17,.015,0),'Dark',p,False,'Cylinder')
  self.mesh('AssentoLado',(-.21,.53,0),(.07,.035,.40),'Ceramic',p)
  self.mesh('AssentoLado',(.21,.53,0),(.07,.035,.40),'Ceramic',p)
  self.mesh('Divisoria',(.54,.95,0),(.045,1.9,1.35),'Blue',p,True)
 def sink(self,x,z):
  if not self.reserve(x,z,1,.65): return
  p=self.group('PiaEspelho',x,z)
  self.mesh('GabinetePia',(0,.40,0),(.76,.78,.46),'Blue',p,True)
  for side in (-.36,.36): self.mesh('SuporteEspelho',(side,1.20,-.28),(.045,.90,.045),'Steel',p)
  self.mesh('Pia',(0,.83,0),(.85,.15,.53),'Ceramic',p,True)
  self.mesh('Cuba',(0,.911,.05),(.54,.012,.31),'Dark',p)
  self.mesh('Torneira',(0,1.01,-.19),(.04,.24,.04),'Steel',p)
  self.mesh('Bica',(0,1.12,-.12),(.04,.04,.19),'Steel',p)
  self.mesh('MolduraEspelho',(0,1.6,-.28),(.83,.76,.06),'Steel',p,True)
  self.mesh('Espelho',(0,1.6,-.244),(.73,.66,.012),'Glass',p)
  self.mesh('Trinca',(0,1.6,-.235),(.008,.61,.008),'Dark',p,rot=(0,0,.35))
 def exhibit(self,x,z,i):
  if not self.reserve(x,z,.8,.8): return
  p=self.group('Expositor',x,z)
  self.mesh('Pedestal',(0,.50,0),(.65,1,.65),'Wood',p,True)
  self.mesh('ComputadorHistorico',(0,1.20,0),(.48,.39,.41),'Ceramic',p)
  self.mesh('TelaAntiga',(0,1.20,.21),(.34,.25,.012),'Dark',p)
  self.mesh('Placa',(0,.80,.332),(.51,.19,.012),'Paper',p)
  self.label('ACERVO 0'+str(i),(0,.80,.344),p,14)
 def save(self,path): path.write_text('[gd_scene format=3]\n\n'+'\n\n'.join(self.res+self.nodes)+'\n',encoding='utf-8')
rooms=[]
for b in blocks:
 h=b.splitlines()[0]
 if 'parent="."' not in h: continue
 name=re.search(r'name="([^"]+)"',h)[1]
 if not any(t in name for t in ('Sala','Laboratorio','Banheiro')): continue
 if any('parent="'+name+'"' in q.splitlines()[0] and 'name="Decor"' in q.splitlines()[0] and 'decor_all_' not in q.splitlines()[0] for q in blocks): continue
 md=re.search(r'mesh_data = SubResource\("([^"]+)"\)',b)
 if not md: continue
 rb=re.search(r'\[sub_resource[^\n]*id="'+md[1]+r'"\].*?(?=\n\[)',s,re.S)[0]
 nums=list(map(float,re.search(r'positions = PackedVector3Array\(([^)]+)',rb)[1].split(',')))
 lo=[min(nums[i::3]) for i in range(3)]; hi=[max(nums[i::3]) for i in range(3)]
 w,d=hi[0]-lo[0],hi[2]-lo[2]; decor=Decor(name,w,d,hi[1]-lo[1]); theme='storage'
 for cb in blocks:
  if 'parent="'+name+'"' not in cb.splitlines()[0]: continue
  t=re.search(r'transform = Transform3D\(([^)]+)',cb)
  if t:
   vals=list(map(float,t[1].split(','))); decor.missions.append((vals[-3]-lo[0],vals[-1]-lo[2]))
 if 'Laboratorio' in name or 'DeAula' in name:
  theme='laboratory' if 'Laboratorio' in name else 'classroom'
  # Longitudinal rows, with an aisle of at least 1 m between pairs of rows.
  for zi in range(max(1,int((d-2.9)/2.5)+1)):
   z=1.65+zi*2.5
   for xi in range(max(1,int((w-3.2)/1.65)+1)): decor.desk(1.6+xi*1.65,z,theme=='laboratory')
  decor.board('CIENCIA DA COMPUTACAO' if theme=='laboratory' else 'SALA DE AULA','LABORATORIO / REDES E SISTEMAS' if theme=='laboratory' else 'ALGORITMOS - AULA INTERROMPIDA')
 elif 'Professor' in name:
  theme='office'; decor.desk(w/2,d/2,True)
  decor.shelf(1.4,d-1.2); decor.shelf(w-1.4,d-1.2)
  decor.board('GABINETE DO PROFESSOR','ORIENTACOES / PESQUISA / TCC')
 elif 'Banheiro' in name:
  theme='bathroom'
  for x in (1.5,3.2,4.9,6.6): decor.toilet(x,1.65)
  for x in (1.5,3.2,4.9): decor.sink(x,d-1.2)
  decor.board('SANITARIOS','INTERDITADO PARA MANUTENCAO')
 elif 'Energia' in name:
  theme='power'; decor.shelf(w-1.5,d-1.2,'boxes')
  decor.board('PERIGO - ALTA TENSAO','ACESSO RESTRITO / QUADRO GERAL')
  for x in (.35,.55): decor.mesh('Eletroduto',(x,2.9,.06),(.045,1.5,.045),'Steel')
 elif 'Ferramentas' in name:
  theme='workshop'; decor.desk(w/2,d/2)
  for x in (1.4,w-1.4): decor.shelf(x,d-1.2,'boxes')
  decor.board('OFICINA DE MANUTENCAO','DEVOLVER FERRAMENTAS APOS O USO')
  for j in range(6):
   x=w/2-.8+j*.3
   decor.mesh('FerramentaCabo',(x,1.8,.13),(.035,.32,.055),'Wood')
   decor.mesh('FerramentaCabeca',(x,1.96,.13),(.14,.06,.06),'Steel')
 elif 'Museu' in name:
  theme='museum'
  for i,(x,z) in enumerate(((1.6,1.6),(w-1.6,1.6),(1.6,d-1.6),(w-1.6,d-1.6))): decor.exhibit(x,z,i+1)
  decor.board('MEMORIA DA COMPUTACAO','ACERVO / TERMINAIS HISTORICOS')
 elif 'Chaves' in name:
  theme='keys'; decor.shelf(w-1.5,d-1.2,'files')
  decor.board('CONTROLE DE CHAVES','REGISTRO DE RETIRADA / ACESSO RESTRITO')
  for i in range(8):
   x=w/2-.7+i*.20
   decor.mesh('ChaveExposicao',(x,1.9,.12),(.025,.16,.025),'Steel')
   decor.mesh('EtiquetaChave',(x,1.74,.12),(.12,.12,.015),'Paper')
 elif 'Secreta' in name:
  theme='secret'; decor.desk(w/2,d/2); decor.shelf(w-1.5,d-1.2)
  decor.board('ARQUIVO CONFIDENCIAL','BUTCHER / IDENTIDADE DESCONHECIDA')
  for i in range(3):
   decor.mesh('DossieParede',(w/2-.6+i*.6,1.7,.045),(.43,.6,.015),'Paper')
   decor.label('REGISTRO 0'+str(i+1),(w/2-.6+i*.6,1.7,.06),size=13)
 elif 'TCC' in name or 'Apresenta' in name:
  theme='presentation'; decor.desk(w/2,1.65)
  for x in (1.5,w-1.5): decor.desk(x,d-1.65)
  decor.board('BANCA DE TCC','PROJETO FINAL / CIENCIA DA COMPUTACAO')
 else:
  theme='abandoned' if 'Abandonada' in name or 'Vazia' in name else 'storage'
  for x in (1.4,w-1.4): decor.shelf(x,d-1.2,'boxes')
  if w>4 and d>4: decor.desk(w/2,1.65)
  decor.board('DEPOSITO' if theme=='storage' else 'SALA DESATIVADA','MATERIAL ARQUIVADO / NAO REMOVER')
  # Narrow pantry uses shallow wall-mounted stock above walking height.
  if w<3:
   decor.mesh('PrateleiraAlta',(w/2,2.05,.24),(w-.25,.06,.43),'Wood')
   for j in range(3): decor.mesh('LataMantimento',(.4+j*.55,2.23,.24),(.15,.29,0),'Ceramic',kind='Cylinder')
 decor.common()
 path=OUT/(slug(name)+'Decor.tscn'); decor.save(path)
 key='decor_all_'+slug(name); rel=path.relative_to(ROOT).as_posix()
 if f'id="{key}"' not in s:
  at=s.index('[sub_resource'); s=s[:at]+f'[ext_resource type="PackedScene" path="res://{rel}" id="{key}"]\n\n'+s[at:]
  s+=f'\n[node name="Decor" parent="{name}" instance=ExtResource("{key}")]\nposition = {vec(lo)}\n'
 rooms.append({'room':name,'theme':theme,'meshes':decor.count,'furniture':len(decor.occupied),'size':[w,d],'path':rel})
SCENE.write_text(s,encoding='utf-8')
(ROOT/'tools/decor/room_decor_manifest.json').write_text(json.dumps(rooms,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(rooms,ensure_ascii=True,indent=1))
