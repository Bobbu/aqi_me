// Helpers for matching a user-typed region qualifier (the part after the comma
// in "City, State" / "City, Country") against a geocoding result's region, so
// queries like "Chicago, IL" or "Washington, DC" resolve. Open-Meteo only
// matches the bare place name, so we do the region filtering ourselves.

/// US state / territory postal abbreviations → the full `admin1` name Open-Meteo
/// returns. Lowercase keys and values.
const Map<String, String> kUsStateAbbreviations = <String, String>{
  'al': 'alabama',
  'ak': 'alaska',
  'az': 'arizona',
  'ar': 'arkansas',
  'ca': 'california',
  'co': 'colorado',
  'ct': 'connecticut',
  'de': 'delaware',
  'dc': 'district of columbia',
  'fl': 'florida',
  'ga': 'georgia',
  'hi': 'hawaii',
  'id': 'idaho',
  'il': 'illinois',
  'in': 'indiana',
  'ia': 'iowa',
  'ks': 'kansas',
  'ky': 'kentucky',
  'la': 'louisiana',
  'me': 'maine',
  'md': 'maryland',
  'ma': 'massachusetts',
  'mi': 'michigan',
  'mn': 'minnesota',
  'ms': 'mississippi',
  'mo': 'missouri',
  'mt': 'montana',
  'ne': 'nebraska',
  'nv': 'nevada',
  'nh': 'new hampshire',
  'nj': 'new jersey',
  'nm': 'new mexico',
  'ny': 'new york',
  'nc': 'north carolina',
  'nd': 'north dakota',
  'oh': 'ohio',
  'ok': 'oklahoma',
  'or': 'oregon',
  'pa': 'pennsylvania',
  'ri': 'rhode island',
  'sc': 'south carolina',
  'sd': 'south dakota',
  'tn': 'tennessee',
  'tx': 'texas',
  'ut': 'utah',
  'vt': 'vermont',
  'va': 'virginia',
  'wa': 'washington',
  'wv': 'west virginia',
  'wi': 'wisconsin',
  'wy': 'wyoming',
  'pr': 'puerto rico',
  'gu': 'guam',
  'vi': 'united states virgin islands',
  'as': 'american samoa',
  'mp': 'northern mariana islands',
};

/// Common country shorthands → ISO country code (lowercase) Open-Meteo returns.
const Map<String, String> kCountrySynonyms = <String, String>{
  'usa': 'us',
  'u.s.': 'us',
  'u.s.a.': 'us',
  'america': 'us',
  'uk': 'gb',
  'u.k.': 'gb',
  'britain': 'gb',
  'england': 'gb',
  'uae': 'ae',
};

/// Whether a single [qualifier] (e.g. "IL", "Illinois", "USA") matches the
/// region of a geocoding candidate. Short qualifiers (≤3 chars) are treated as
/// abbreviations/codes only — never loose substrings — so "Chicago, IN" doesn't
/// accidentally match Illinois.
bool regionQualifierMatches(
  String qualifier, {
  String? admin1,
  String? country,
  String? countryCode,
}) {
  final String q = qualifier.trim().toLowerCase();
  if (q.isEmpty) return true;

  final String? a1 = admin1?.toLowerCase();
  final String? co = country?.toLowerCase();
  final String? cc = countryCode?.toLowerCase();

  // Country code (2-letter) and common shorthands.
  if (cc != null) {
    if (cc == q) return true;
    if (kCountrySynonyms[q] == cc) return true;
  }

  // US state / territory abbreviation → full admin1 name.
  final String? expandedState = kUsStateAbbreviations[q];
  if (expandedState != null && a1 == expandedState) return true;

  // Exact name matches.
  if (a1 == q || co == q) return true;

  // Substring match only for longer, unambiguous qualifiers.
  if (q.length >= 4) {
    if (a1 != null && a1.contains(q)) return true;
    if (co != null && co.contains(q)) return true;
  }

  return false;
}
