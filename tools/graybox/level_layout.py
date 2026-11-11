"""Metric layout reconstructed from the annotated floor plan. Y is vertical."""
WIDTH = 2.62  # 2.50 m clear between 0.12 m walls.
rooms = []
corridors = []

def corridor(x1, z1, x2, z2):
    assert abs(min(x2 - x1, z2 - z1) - WIDTH) < 1e-6
    corridors.append((x1, z1, x2, z2))

def room(name, x1, z1, x2, z2, side, door):
    rooms.append((name, x1, z1, x2, z2, side, door))

# Northern spine, northern cross passage, eastern spine and west stair access.
corridor(0, -4, WIDTH, 40)
corridor(-8, 6, 18.62, 8.62)
corridor(16, -5, 18.62, 40)
corridor(-10, 30, -7.38, 42.62)
corridor(-10, 40, 27, 42.62)
# Southern spines and lower cross passages.
corridor(-6, 42.62, -3.38, 90.62)
corridor(19, 42.62, 21.62, 94)
corridor(-13, 88, 19, 90.62)
corridor(5, 81, 19, 83.62)
corridor(-13, 88, -10.38, 94)
corridor(5, 81, 7.62, 93)

room('Dispensa_Norte', -8, -5, -4, 6, 'S', -6)
room('Sala_Vazia_Norte_01', -4, -4, 0, 0, 'E', -2)
room('Sala_Vazia_Norte_02', -4, 0.4, 0, 6, 'E', 3)
room('Chaves', WIDTH, -4, 7, 0, 'W', -2)
room('Sala_Secreta_Norte', WIDTH, 0.4, 7, 5, 'W', 2)
room('Sala_Abandonada_Norte_01', 9, -4, 16, 1, 'E', -1)
room('Sala_Vazia_Norte_03', 9, 1.4, 16, 6, 'E', 4)
room('Gerador', 18.62, -3, 28, 2, 'W', -1)
room('Dispensa_02', 18.62, 3, 23, 8.62, 'W', 7)
for name, z1, z2 in [('Sala_Aula_Norte_03',8.62,16),('Sala_Aula_Norte_02',17,23),('Sala_Aula_Norte_01',24,30)]:
    room(name,-7 if name == 'Sala_Aula_Norte_01' else -8,z1,0,z2,'E',z2-1)
room('Sala_Aula_Norte_04',WIDTH,8.62,8,16,'W',15)
room('Sala_Aula_Norte_05',WIDTH,20,8,25,'W',22)
room('Sala_Aula_Norte_06',WIDTH,25.4,8,32,'W',30)
room('Banheiro_Feminino_Norte_01',WIDTH,32.4,8,36.5,'S',4)
corridor(WIDTH,36.5,8,39.12)
room('Sala_Abandonada_Norte_02',8.4,8.62,12,16,'N',10)
room('Sala_Norte_Interna',12.4,8.62,16,12,'N',14)
for name,z1,z2 in [('Sala_Aula_Norte_07',17,23),('Banheiro_Masculino_Norte_01',23.4,29),('Banheiro_Feminino_Norte_02',30,35),('Sala_Aula_Norte_12',35.4,40)]:
    room(name,9,z1,16,z2,'E',(z1+z2)/2)
for number,z1,z2 in [(8,10,17),(9,19,25),(10,26,32),(11,33,40)]:
    room(f'Sala_Aula_Norte_{number:02}',18.62,z1,25,z2,'W',(z1+z2)/2)
room('Sala_Aula_Extra_01',-19,26,-7.38,30,'S',-8.69)
room('Sala_Aula_Extra_02',-19,32,-10,36,'E',34)
room('Sala_Ferramentas',-19,36.4,-10,40,'E',38)
# Two short side landings on the western southern corridor.
corridor(-8.62,57,-3.38,59.62)
corridor(-9.5,71,-3.38,73.62)
room('Diretoria',-17,50,-6,57,'S',-7.31)
room('Achados_Perdidos',-17,59.62,-6,64,'N',-7.31)
room('Sala_Aula_Sul_04',-17,66,-6,71,'S',-7.8)
room('Sala_Vazia_Oeste',-16,71,-9.5,73.62,'E',72.31)
room('Sala_Aula_Sul_03',-17,73.62,-6,79,'N',-7.8)
room('Sala_Reunioes_01',-17,79.4,-6,83.5,'E',81)
room('Sala_Perigosa',-17,84,-6,88,'E',86)
room('Banheiro_Feminino_Sul',-3.38,52,3,57.8,'W',56)
room('Banheiro_Masculino_Sul',-3.38,58.2,3,65,'W',60)
room('Monitoria_01',-3.38,72,3,77,'W',75)
room('Monitoria_02',-3.38,77.4,3,85,'W',83)
room('Sala_Vazia_Sul',-3.38,85.4,5,88,'E',86.7)
# Every lab/professor pair has a 2.5 m clear lateral connection to the spine.
for index,z in enumerate([45,51.5,58,64.5,71],1):
    corridor(17,z+2,23,z+4.62)
    room(f'Laboratorio_{index:02}' if index<5 else 'Sala_TCC',7,z,17,z+6,'E',z+3.31)
    room(f'Professor_{index:02}',23,z,30,z+6,'W',z+3.31)
room('Anexo_Professor_01',30,45,34,51,'W',48.31)
room('Sala_Apresentacao',5,77,11,81,'S',6.5)
room('Sala_Vazia_Central',11.4,77,17,81,'S',13)
room('Sala_Aula_Sul_02',8,83.62,13,88,'N',11)
room('Sala_Aula_Sul_01',13.4,83.62,19,88,'N',15)
room('Professor_08',21.62,87,28,91,'W',89)
room('Professor_07',21.62,91.4,28,96,'W',93)
room('Dispensa_Sul',-20,88,-13,92,'E',89.3)
room('Sala_Secreta_Sul',-10.38,90.62,-1,96,'W',92)

# Stair flights are enclosed separately and blocked at their entrances.
stairs = [(-7.38,30,0,34.5),(-7.38,35,0,39.5)]
