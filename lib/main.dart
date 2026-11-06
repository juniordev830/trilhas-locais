import 'package:flutter/material.dart';
import 'trails.dart';
void main()=>runApp(const TrailsApp());
class TrailsApp extends StatelessWidget {
 const TrailsApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'Trilhas Locais',theme:ThemeData(colorSchemeSeed:Colors.green,useMaterial3:true),home:const TrailsHome());
}
class TrailsHome extends StatefulWidget {const TrailsHome({super.key});@override State<TrailsHome> createState()=>_TrailsHomeState();}
class _TrailsHomeState extends State<TrailsHome>{
 final List<Trail> trails=[];final Set<int> favorites={};int nextId=1;double maxKm=30;String filterDifficulty='Todas';bool onlyFavorites=false;
 Future<void> addTrail() async {
  final name=TextEditingController(),distance=TextEditingController(),notes=TextEditingController();
  String difficulty='Fácil';
  final newTrail=await showDialog<Trail>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setDialog)=>AlertDialog(
   title:const Text('Novo percurso'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:'Nome')),TextField(controller:distance,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Distância em km')),
    DropdownButtonFormField<String>(initialValue:difficulty,decoration:const InputDecoration(labelText:'Dificuldade'),items:difficulties.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setDialog(()=>difficulty=v??'Fácil')),
    TextField(controller:notes,decoration:const InputDecoration(labelText:'Observações'))])),
   actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),FilledButton(onPressed:(){
    try{final km=double.parse(distance.text.replaceAll(',','.'));final t=createTrail(nextId,name.text,km,difficulty,notes.text);Navigator.pop(context,t);}
    catch(_){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Confira nome, distância e dificuldade.')));}
   },child:const Text('Salvar'))],
  )));
  name.dispose();distance.dispose();notes.dispose();
  if(newTrail!=null){setState((){trails.add(newTrail);nextId++;});}
 }
 @override Widget build(BuildContext context){
  final visible=filterTrails(trails,maxKm:maxKm,difficulty:filterDifficulty=='Todas'?null:filterDifficulty).where((t)=>!onlyFavorites||favorites.contains(t.id)).toList();
  return Scaffold(appBar:AppBar(title:const Text('🥾 Trilhas Locais')),floatingActionButton:FloatingActionButton.extended(onPressed:addTrail,icon:const Icon(Icons.add),label:const Text('Adicionar')),
   body:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Catálogo manual: o aplicativo não solicita nem coleta sua localização.'),
    Text('Distância máxima: ${maxKm.toStringAsFixed(0)} km'),Slider(value:maxKm,min:0,max:30,divisions:30,onChanged:(v)=>setState(()=>maxKm=v)),
    DropdownButtonFormField<String>(initialValue:filterDifficulty,decoration:const InputDecoration(labelText:'Dificuldade'),items:['Todas',...difficulties].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>filterDifficulty=v??'Todas')),
    SwitchListTile(title:const Text('Somente favoritos'),value:onlyFavorites,onChanged:(v)=>setState(()=>onlyFavorites=v)),
    if(visible.isEmpty) const Padding(padding:EdgeInsets.all(20),child:Text('Nenhuma trilha corresponde aos filtros.')),
    ...visible.map((t)=>Card(child:ListTile(title:Text(t.name),subtitle:Text('${t.distanceKm.toStringAsFixed(1)} km · ${t.difficulty}\n${t.notes}'),isThreeLine:t.notes.isNotEmpty,trailing:IconButton(tooltip:'Alternar favorito',icon:Icon(favorites.contains(t.id)?Icons.star:Icons.star_border),onPressed:()=>setState(()=>favorites.contains(t.id)?favorites.remove(t.id):favorites.add(t.id)))))),
   ]));
 }
}
