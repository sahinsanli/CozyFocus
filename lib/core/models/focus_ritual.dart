const focusRitualSoundIds = <String>{'rain', 'fire', 'forest', 'piano'};
const focusRitualFocusOptions = <int>[15, 25, 45, 60, 75, 90];
const focusRitualBreakOptions = <int>[5, 10, 15];

class FocusRitual {
  const FocusRitual({
    required this.id,
    required this.focusMinutes,
    required this.breakMinutes,
    this.templateKey,
    this.customName,
    this.soundVolumes = const {},
  });

  final String id;
  final String? templateKey;
  final String? customName;
  final int focusMinutes;
  final int breakMinutes;
  final Map<String, double> soundVolumes;

  FocusRitual copyWith({
    String? id,
    String? templateKey,
    String? customName,
    int? focusMinutes,
    int? breakMinutes,
    Map<String, double>? soundVolumes,
    bool clearCustomName = false,
  }) => FocusRitual(
    id: id ?? this.id,
    templateKey: templateKey ?? this.templateKey,
    customName: clearCustomName ? null : customName ?? this.customName,
    focusMinutes: focusMinutes ?? this.focusMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    soundVolumes: soundVolumes ?? this.soundVolumes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateKey': templateKey,
    'customName': customName,
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'soundVolumes': soundVolumes,
  };

  factory FocusRitual.fromJson(Map<String, dynamic> json) => FocusRitual(
    id: json['id'] as String? ?? '',
    templateKey: json['templateKey'] as String?,
    customName: json['customName'] as String?,
    focusMinutes: (json['focusMinutes'] as num?)?.toInt() ?? 25,
    breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 5,
    soundVolumes: _doubleMap(json['soundVolumes']),
  );
}

class FocusRitualCollection {
  const FocusRitualCollection({
    this.rituals = defaultFocusRituals,
    this.selectedRitualId,
    this.updatedAtEpochMs = 0,
  });

  final List<FocusRitual> rituals;
  final String? selectedRitualId;
  final int updatedAtEpochMs;

  FocusRitualCollection copyWith({
    List<FocusRitual>? rituals,
    String? selectedRitualId,
    int? updatedAtEpochMs,
    bool clearSelection = false,
  }) => FocusRitualCollection(
    rituals: rituals ?? this.rituals,
    selectedRitualId: clearSelection
        ? null
        : selectedRitualId ?? this.selectedRitualId,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
  );

  Map<String, dynamic> toJson() => {
    'items': rituals.map((ritual) => ritual.toJson()).toList(),
    'selectedRitualId': selectedRitualId,
    'updatedAtEpochMs': updatedAtEpochMs,
  };

  factory FocusRitualCollection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rituals = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => FocusRitual.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <FocusRitual>[];
    return FocusRitualCollection(
      rituals: rawItems is List ? rituals : defaultFocusRituals,
      selectedRitualId: json['selectedRitualId'] as String?,
      updatedAtEpochMs: (json['updatedAtEpochMs'] as num?)?.toInt() ?? 0,
    );
  }
}

const defaultFocusRituals = <FocusRitual>[
  FocusRitual(
    id: 'study',
    templateKey: 'study',
    focusMinutes: 45,
    breakMinutes: 10,
    soundVolumes: {'rain': .45, 'piano': .30},
  ),
  FocusRitual(
    id: 'reading',
    templateKey: 'reading',
    focusMinutes: 25,
    breakMinutes: 5,
    soundVolumes: {'fire': .45},
  ),
  FocusRitual(
    id: 'deep-focus',
    templateKey: 'deepFocus',
    focusMinutes: 90,
    breakMinutes: 15,
    soundVolumes: {'forest': .50, 'piano': .20},
  ),
];

Map<String, double> _doubleMap(Object? value) => value is Map
    ? value.map(
        (key, item) =>
            MapEntry(key.toString(), (item as num?)?.toDouble() ?? 0),
      )
    : <String, double>{};
