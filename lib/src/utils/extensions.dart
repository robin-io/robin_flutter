extension MapX<K, V> on Map<K, V> {
  bool updateKey({required K currentKey, required K newKey}) {
    if (containsKey(currentKey) && !containsKey(newKey)) {
      final value = this[currentKey] as V;
      final index = keys.toList().indexWhere((k) => k == currentKey);
      final mapEntriesList = entries.toList();
      mapEntriesList.removeAt(index);
      mapEntriesList.insert(index, MapEntry<K, V>(newKey, value));
      clear();
      addEntries(mapEntriesList);
      return true;
    } else {
      return false;
    }
  }
}
