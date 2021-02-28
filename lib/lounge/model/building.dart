import 'package:hive/hive.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'area.dart';

class Building {
  String id;
  String name;
  String campus;
  Map<String, Area> areas;

  Building({this.id, this.name, this.campus, this.areas});

  static Building fromMap(Map<String, dynamic> map, {bool newApi = true}) {
    if (map == null) return null;
    Building building = Building();
    building.id = map['building_id'] ?? '';
    building.name = map['building'] ?? '';
    building.campus = map['campus_id'] ?? '';
    if (newApi) {
      var list = List()
        ..addAll((map['areas'] as List ?? []).map((e) => Area.fromMap(e)));
      for (var area in list) {
        building.areas[area.id ?? ''] = area;
      }
      return building;
    } else {
      List<Classroom> list = List()
        ..addAll((map['classrooms'] as List ?? []).map((e) {
          return Classroom.fromMap(e, newApi: false);
        }));
      var as = list.map((e) => e.aId).toSet().toList();
      as.sort();
      building.areas = {};
      for (var a in as) {
        Map<String, Classroom> cs = {};
        cs.addEntries(list
            .where((element) => element.aId == a)
            .map((e) => MapEntry(e.id, e)));
        building.areas[a] = Area(id: a, classrooms: cs);
      }

      return building;
    }
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "campus": campus,
        "areas": areas,
      };
}

class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = 1;

  @override
  Building read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Building(
      id: fields[0] as String,
      name: fields[1] as String,
      campus: fields[2] as String,
      areas: (fields[3] as Map)?.cast<String, Area>(),
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.campus)
      ..writeByte(3)
      ..write(obj.areas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
