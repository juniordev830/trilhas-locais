class Trail {
 final int id;
 final String name;
 final double distanceKm;
 final String difficulty;
 final String notes;
 const Trail({required this.id,required this.name,required this.distanceKm,required this.difficulty,required this.notes});
}
const difficulties=['Fácil','Moderada','Difícil'];
Trail createTrail(int id,String name,double km,String difficulty,String notes) {
 if(name.trim().isEmpty) throw ArgumentError('Informe o percurso.');
 if(!km.isFinite || km<=0) throw ArgumentError('Distância inválida.');
 if(!difficulties.contains(difficulty)) throw ArgumentError('Dificuldade inválida.');
 return Trail(id:id,name:name.trim(),distanceKm:km,difficulty:difficulty,notes:notes.trim());
}
List<Trail> filterTrails(List<Trail> trails,{double? maxKm,String? difficulty}){
 if(maxKm!=null && (!maxKm.isFinite || maxKm<0)) throw ArgumentError('Limite inválido');
 return trails.where((t)=>(maxKm==null||t.distanceKm<=maxKm)&&(difficulty==null||t.difficulty==difficulty)).toList();
}
