import 'package:flutter_test/flutter_test.dart';
import 'package:trilhas_locais/trails.dart';
void main(){
 test('filtro de 5 km exclui percursos acima do limite',(){
  final a=createTrail(1,'Curta',3,'Fácil','');
  final b=createTrail(2,'Longa',8,'Difícil','');
  expect(filterTrails([a,b],maxKm:5).map((x)=>x.id).toList(),[1]);
  expect(filterTrails([a,b],difficulty:'Difícil').single.id,2);
 });
 test('impede distância e dificuldade inválidas',(){
  expect(()=>createTrail(1,'',3,'Fácil',''),throwsArgumentError);
  expect(()=>createTrail(1,'X',-1,'Fácil',''),throwsArgumentError);
  expect(()=>createTrail(1,'X',2,'Desconhecida',''),throwsArgumentError);
 });
}
