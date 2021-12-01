
public static func InitializeScripts() -> Void {
  Log("InitializeScripts");
  StatsEffectsEnumToTDBID(-1);
}

public static func LogDamage(const str: script_ref<String>) -> Void {
  LogChannel(n"Damage", str);
}

public static func LogDM(const str: script_ref<String>) -> Void {
  LogChannel(n"DevelopmentManager", str);
}

public static func LogItems(const str: script_ref<String>) -> Void {
  LogChannel(n"Items", str);
}

public static func LogStats(const str: script_ref<String>) -> Void {
  LogChannel(n"Stats", str);
}

public static func LogStatPools(const str: script_ref<String>) -> Void {
  LogChannel(n"StatPools", str);
}

public static func LogStrike(const str: script_ref<String>) -> Void {
  LogChannel(n"Strike", str);
}

public static func LogItemManager(const str: script_ref<String>) -> Void {
  LogChannel(n"ItemManager", str);
}

public static func LogScanner(const str: script_ref<String>) -> Void {
  LogChannel(n"Scanner", str);
}

public static func LogAI(const str: script_ref<String>) -> Void {
  LogChannel(n"AI", str);
}

public static func LogAIError(const str: script_ref<String>) -> Void {
  LogChannelError(n"AI", str);
  ReportFailure(str);
}

public static func LogAIWarning(const str: script_ref<String>) -> Void {
  LogChannelWarning(n"AI", str);
}

public static func LogAICover(const str: script_ref<String>) -> Void {
  LogChannel(n"AICover", str);
}

public static func LogAICoverWarning(const str: script_ref<String>) -> Void {
  LogChannelError(n"AICover", str);
}

public static func LogAICoverError(const str: script_ref<String>) -> Void {
  LogChannelWarning(n"AICover", str);
}

public static func LogPuppet(const str: script_ref<String>) -> Void {
  LogChannel(n"Puppet", str);
}

public static func LogUI(const str: script_ref<String>) -> Void {
  LogChannel(n"UI", str);
}

public static func LogUIWarning(const str: script_ref<String>) -> Void {
  LogChannelWarning(n"UI", str);
}

public static func LogUIError(const str: script_ref<String>) -> Void {
  LogChannelError(n"UI", str);
}

public static func LogVehicles(const str: script_ref<String>) -> Void {
  LogChannel(n"Vehicles", str);
}

public static func LogTargetManager(const str: script_ref<String>, opt type: CName) -> Void {
  FindProperLog(n"TargetManager", type, str);
}

public static func LogDevices(const str: script_ref<String>, opt type: ELogType) -> Void {
  if IsFinal() {
    return;
  };
  FindProperLog(n"Device", type, str);
}

public static func LogDevices(const object: ref<IScriptable>, const str: script_ref<String>, opt type: ELogType) -> Void {
  let address: String;
  let deviceObj: ref<Device>;
  let devicePS: ref<ScriptableDeviceComponentPS>;
  let deviceSpecificTags: String;
  let extendedString: String;
  let id: String;
  let isOverride: Int32;
  let puppetPS: ref<ScriptedPuppetPS>;
  let tooltip: String;
  return;
}

public static func LogDevices(const object: ref<SecuritySystemControllerPS>, input: ref<SecuritySystemInput>, const str: script_ref<String>, opt type: ELogType) -> Void {
  let message: String;
  let prefix: String;
  if IsFinal() {
    return;
  };
  prefix = "SecuritySystemInput [ Frame: " + IntToString(Cast(GameInstance.GetFrameNumber(object.GetGameInstance()))) + " @" + " | ID #" + input.GetID() + " ]";
  message = prefix + " " + str;
  LogDevices(object, message, type);
}

public static func LogDevices(const object: ref<SecuritySystemControllerPS>, id: Int32, const str: script_ref<String>, opt type: ELogType) -> Void {
  let message: String;
  let prefix: String;
  if IsFinal() {
    return;
  };
  prefix = "Most recent accepted ID [ Frame: " + IntToString(Cast(GameInstance.GetFrameNumber(object.GetGameInstance()))) + " @" + id + " ]";
  message = prefix + " " + str;
  LogDevices(object, message, type);
}

public static func LogDevices(const object: ref<SecurityAreaControllerPS>, id: Int32, const str: script_ref<String>, opt type: ELogType) -> Void {
  let message: String;
  let prefix: String;
  if IsFinal() {
    return;
  };
  prefix = "[ Frame: " + IntToString(Cast(GameInstance.GetFrameNumber(object.GetGameInstance()))) + " #" + id + " ]";
  message = prefix + " " + str;
  LogDevices(object, message, type);
}

public static func FindProperLog(channelName: CName, logType: ELogType, const message: script_ref<String>) -> Void {
  switch logType {
    case ELogType.WARNING:
      LogChannelWarning(channelName, message);
      break;
    case ELogType.ERROR:
      LogChannelError(channelName, message);
      break;
    default:
      LogChannel(channelName, message);
  };
}

public static func FindProperLog(channelName: CName, logType: CName, const message: script_ref<String>) -> Void {
  if Equals(logType, n"Warning") || Equals(logType, n"warning") || Equals(logType, n"w") {
    LogChannelWarning(channelName, message);
  } else {
    if Equals(logType, n"Error") || Equals(logType, n"error") || Equals(logType, n"e") {
      LogChannelError(channelName, message);
    } else {
      LogChannel(channelName, message);
    };
  };
}

public static func LogAssert(condition: Bool, const text: script_ref<String>) -> Void {
  if !condition {
    LogChannel(n"ASSERT", text);
  };
}

public static exec func CastEnum() -> Void {
  let enumState: EDeviceStatus = EDeviceStatus.DISABLED;
  let value: Int32 = EnumInt(enumState);
  switch value {
    case -2:
      Log("Disabled " + IntToString(value));
      break;
    case -1:
      Log("Unpowered " + IntToString(value));
      break;
    case 0:
      Log("Off " + IntToString(value));
      break;
    case 1:
      Log("On " + IntToString(value));
      break;
    default:
      Log("wtf " + IntToString(value));
  };
}

public static exec func GetFunFact() -> Void {
  let RNG: Int32 = RandRange(0, 23);
  switch RNG {
    case 0:
      Log("Duck vaginas are spiral shaped with dead ends.");
      break;
    case 1:
      Log("Plural of axolotl is axolotls");
      break;
    case 2:
      Log("In the UK, it is illegal to eat mince pies on Christmas Day!");
      break;
    case 3:
      Log("Pteronophobia is the fear of being tickled by feathers!");
      break;
    case 4:
      Log("When hippos are upset, their sweat turns red.");
      break;
    case 5:
      Log("The average woman uses her height in lipstick every 5 years.");
      break;
    case 6:
      Log(" Cherophobia is the fear of fun");
      break;
    case 7:
      Log("If Pinokio says \u{e2}\u{80}\u{9c}My Nose Will Grow Now\u{e2}\u{80}\u{9d}, it would cause a paradox. ");
      break;
    case 8:
      Log("Billy goats urinate on their own heads to smell more attractive to females.");
      break;
    case 9:
      Log("The person who invented the Frisbee was cremated and made into a frisbee after he died!");
      break;
    case 10:
      Log("If you consistently fart for 6 years & 9 months, enough gas is produced to create the energy of an atomic bomb!");
      break;
    case 11:
      Log("McDonalds calls frequent buyers of their food \u{e2}\u{80}\u{9c}heavy users.");
      break;
    case 12:
      Log("Guinness Book of Records holds the record for being the book most often stolen from Public Libraries.");
      break;
    case 13:
      Log("In Romania it is illegal to performe pantimime as it is considered to be higly offensive");
    case 14:
      Log("Banging your head against a wall can burn 150 calories per hour");
    case 15:
      Log("Crocodile poop used to be used as a contraception");
      break;
    case 16:
      Log("In Finland they have an official tournament for peaple riding on a fake horses");
      break;
    case 17:
      Log("The Vatican City is the country that drinks the most wine per capita at 74 liters per citizen per year.");
      break;
    case 18:
      Log("It\'s possible to lead a cow upstairs...but not downstairs.");
      break;
    case 19:
      Log("There\'s a chance you won\'t get a fun fact from GetFunFact");
      break;
    case 20:
      Log("For every non-porn webpage, there are five porn pages.");
      break;
    case 21:
      Log("At any given time, at least 0,7% of earth population is drunk.");
      break;
    case 22:
      Log(" You can\u{e2}\u{80}\u{99}t say happiness without saying penis.");
      break;
    default:
      Log("No fact for you. Ha ha!");
  };
}

public static func ProcessCompare(comparator: EComparisonType, valA: Float, valB: Float) -> Bool {
  switch comparator {
    case EComparisonType.Greater:
      return valA > valB;
    case EComparisonType.GreaterOrEqual:
      return valA >= valB;
    case EComparisonType.Equal:
      return valA == valB;
    case EComparisonType.NotEqual:
      return valA != valB;
    case EComparisonType.Less:
      return valA < valB;
    case EComparisonType.LessOrEqual:
      return valA <= valB;
  };
}

public static exec func DetectCycles() -> Void {
  IScriptable.DetectScriptableCycles();
}

public static func ArrayOfScriptedPuppetsAppend(out to: array<ref<ScriptedPuppet>>, from: array<ref<ScriptedPuppet>>) -> Void {
  let i: Int32 = 0;
  while i < ArraySize(from) {
    ArrayPush(to, from[i]);
    i += 1;
  };
}

public static func ManyCNamesIntoSingleString(names: array<CName>, opt separator: String) -> String {
  let outcomeString: String;
  let i: Int32 = 0;
  while i < ArraySize(names) {
    if i == ArraySize(names) - 1 {
      outcomeString += NameToString(names[i]);
    } else {
      outcomeString += NameToString(names[i]) + separator;
    };
    i += 1;
  };
  return outcomeString;
}

public static func IsInRange(value: Int32, a: Int32, b: Int32) -> Bool {
  let max: Int32;
  let min: Int32;
  if a < b {
    min = a;
    max = b;
  } else {
    min = b;
    max = a;
  };
  if value >= min && value <= max {
    return true;
  };
  return false;
}

public static func IsInRange(value: Float, a: Float, b: Float) -> Bool {
  let max: Float;
  let min: Float;
  if a < b {
    min = a;
    max = b;
  } else {
    min = b;
    max = a;
  };
  if value >= min && value <= max {
    return true;
  };
  return false;
}
