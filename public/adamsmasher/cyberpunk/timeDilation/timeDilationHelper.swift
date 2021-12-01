
public class TimeDilationHelper extends IScriptable {

  public final static func GetTimeDilationParameters(out timeDilationParameters: ref<TimeDilationParameters>, profileName: String) -> Void {
    timeDilationParameters = new TimeDilationParameters();
    timeDilationParameters.reason = TimeDilationHelper.GetCNameFromTimeSystemTweak(profileName, "reason");
    timeDilationParameters.timeDilation = TimeDilationHelper.GetFloatFromTimeSystemTweak(profileName, "timeDilation");
    timeDilationParameters.playerTimeDilation = TimeDilationHelper.GetFloatFromTimeSystemTweak(profileName, "playerTimeDilation");
    timeDilationParameters.duration = TimeDilationHelper.GetFloatFromTimeSystemTweak(profileName, "duration");
    timeDilationParameters.easeInCurve = TimeDilationHelper.GetCNameFromTimeSystemTweak(profileName, "easeInCurve");
    timeDilationParameters.easeOutCurve = TimeDilationHelper.GetCNameFromTimeSystemTweak(profileName, "easeOutCurve");
  }

  public final static func SetTimeDilationWithProfile(requester: wref<GameObject>, profileName: String, enable: Bool) -> Bool {
    let duration: Float;
    let easeInCurve: CName;
    let easeOutCurve: CName;
    let playerTimeDilation: Float;
    let reason: CName;
    let timeDilation: Float;
    let timeDilationParameters: ref<TimeDilationParameters>;
    if !IsDefined(requester) {
      return false;
    };
    TimeDilationHelper.GetTimeDilationParameters(timeDilationParameters, profileName);
    reason = timeDilationParameters.reason;
    timeDilation = timeDilationParameters.timeDilation;
    playerTimeDilation = timeDilationParameters.playerTimeDilation;
    duration = timeDilationParameters.duration;
    easeInCurve = timeDilationParameters.easeInCurve;
    easeOutCurve = timeDilationParameters.easeOutCurve;
    if enable {
      TimeDilationHelper.SetTimeDilation(requester, reason, timeDilation, duration, easeInCurve, easeOutCurve);
      TimeDilationHelper.SetTimeDilationOnPlayer(requester, reason, playerTimeDilation, duration, easeInCurve, easeOutCurve);
    } else {
      TimeDilationHelper.UnSetTimeDilation(requester, reason, easeOutCurve);
    };
    return true;
  }

  public final static func SetTimeDilation(requester: wref<GameObject>, reason: CName, timeDilation: Float, opt duration: Float, easeInCurve: CName, easeOutCurve: CName, opt listener: ref<TimeDilationListener>) -> Bool {
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(requester.GetGame());
    if !IsDefined(timeSystem) || timeSystem.IsTimeDilationActive() || IsMultiplayer() {
      return false;
    };
    timeSystem.SetIgnoreTimeDilationOnLocalPlayerZero(false);
    timeSystem.SetTimeDilation(reason, timeDilation, duration, easeInCurve, easeOutCurve, listener);
    return true;
  }

  public final static func SetTimeDilationOnPlayer(requester: wref<GameObject>, reason: CName, timeDilation: Float, opt duration: Float, easeInCurve: CName, easeOutCurve: CName, opt listener: ref<TimeDilationListener>) -> Bool {
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(requester.GetGame());
    if !IsDefined(timeSystem) || timeSystem.IsTimeDilationActive() || IsMultiplayer() {
      return false;
    };
    timeSystem.SetTimeDilationOnLocalPlayerZero(reason, timeDilation, duration, easeInCurve, easeOutCurve);
    return true;
  }

  public final static func UnSetTimeDilation(requester: wref<GameObject>, opt reason: CName, opt easeOutCurve: CName) -> Bool {
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(requester.GetGame());
    if !IsDefined(timeSystem) || !timeSystem.IsTimeDilationActive() || IsMultiplayer() {
      return false;
    };
    if !IsNameValid(easeOutCurve) {
      timeSystem.UnsetTimeDilation(reason, n"");
      timeSystem.UnsetTimeDilationOnLocalPlayerZero(n"");
    } else {
      timeSystem.UnsetTimeDilation(reason, easeOutCurve);
      timeSystem.UnsetTimeDilationOnLocalPlayerZero(easeOutCurve);
    };
    return true;
  }

  public final static func SetIndividualTimeDilation(target: wref<GameObject>, reason: CName, timeDilation: Float, opt duration: Float, opt easeInCurve: CName, opt easeOutCurve: CName) -> Bool {
    if IsMultiplayer() {
      return false;
    };
    (target as gamePuppet).SetIndividualTimeDilation(reason, timeDilation, duration, easeInCurve, easeOutCurve);
    return true;
  }

  public final static func UnsetIndividualTimeDilation(target: wref<GameObject>, opt easeOutCurve: CName) -> Bool {
    if IsMultiplayer() {
      return false;
    };
    (target as gamePuppet).UnsetIndividualTimeDilation(easeOutCurve);
    return true;
  }

  public final static func GetFloatFromTimeSystemTweak(tweakDBPath: String, paramName: String) -> Float {
    return TweakDBInterface.GetFloat(TDBID.Create("timeSystem." + tweakDBPath + "." + paramName), 0.00);
  }

  public final static func GetCNameFromTimeSystemTweak(tweakDBPath: String, paramName: String) -> CName {
    return TweakDBInterface.GetCName(TDBID.Create("timeSystem." + tweakDBPath + "." + paramName), n"");
  }

  public final static func GetSandevistanKey() -> CName {
    return n"sandevistan";
  }

  public final static func GetKerenzikovKey() -> CName {
    return n"kereznikov";
  }

  public final static func GetFocusModeKey() -> CName {
    return n"focusMode";
  }
}
