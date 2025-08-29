/// Planet list
const List<String> planetList = [
  'சூரியன்',
  'சந்திரன்',
  'செவ்வாய்',
  'புதன்',
  'குரு',
  'சுக்கிரன்',
  'சனி',
  'ராகு',
  'கேது',
];

/// Convert planet name → girahamId (index + 1)
int? girahamIdFromPlanet(String planet) {
  final index = planetList.indexOf(planet);
  return index != -1 ? index + 1 : null;
}

/// Convert girahamId → planet name
String? planetFromGirahamId(int id) {
  if (id < 1 || id > planetList.length) return null;
  return planetList[id - 1];
}
