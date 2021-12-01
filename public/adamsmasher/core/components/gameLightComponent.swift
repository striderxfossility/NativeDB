
public native class gameLightComponent extends LightComponent {

  public final native func ToggleLight(on: Bool, opt loop: Bool) -> Void;

  public final native func SetParameters(settings: gameLightSettings, opt inTime: Float, opt interpolationCurve: CName, opt loop: Bool) -> Void;

  public final native func SetStrength(strength: Float, opt inTime: Float) -> Void;

  public final native func SetColor(color: Color, opt inTime: Float) -> Void;

  public final native func SetRadius(radius: Float, opt inTime: Float) -> Void;

  public final native func SetAngles(innerAngle: Float, outerAngle: Float, opt inTime: Float) -> Void;

  public final native func SetIntensity(intensity: Float, opt inTime: Float) -> Void;

  public final native func IsOn() -> Bool;

  public final native func Destroy(opt forceDestroy: Bool, opt skipVFX: Bool) -> Void;

  public final native func IsDestroyed() -> Bool;

  public final native func IsDestructible() -> Bool;

  public final native func SetDestructible(isDestructible: Bool) -> Void;

  public final native func GetOnStrength() -> Bool;

  public final native func GetDefaultSettings() -> gameLightSettings;

  public final native func GetTurnOnTime() -> Float;

  public final native func GetTurnOnCurve() -> CName;

  public final native func GetTurnOffTime() -> Float;

  public final native func GetTurnOffCurve() -> CName;

  public final native func GetCurrentSettings() -> gameLightSettings;

  protected cb func OnToggleLight(evt: ref<ToggleLightEvent>) -> Bool {
    this.ToggleLight(evt.toggle, evt.loop);
  }

  protected cb func OnToggleLightByName(evt: ref<ToggleLightByNameEvent>) -> Bool {
    let fullComponentName: String = NameToString(this.GetName());
    if StrContains(fullComponentName, NameToString(evt.componentName)) {
      this.ToggleLight(evt.toggle);
    };
  }

  protected cb func OnChangeLight(evt: ref<ChangeLightEvent>) -> Bool {
    let lightSettings: gameLightSettings;
    if this.IsEnabled() {
      lightSettings = this.GetCurrentSettings();
      lightSettings.strength = evt.settings.strength;
      lightSettings.color = evt.settings.color;
      this.SetParameters(lightSettings, evt.time, evt.curve, evt.loop);
    };
  }

  protected cb func OnChangeLightByName(evt: ref<ChangeLightByNameEvent>) -> Bool {
    let lightSettings: gameLightSettings;
    let fullComponentName: String = NameToString(this.GetName());
    if this.IsEnabled() && StrContains(fullComponentName, NameToString(evt.componentName)) {
      lightSettings = this.GetCurrentSettings();
      lightSettings.strength = evt.settings.strength;
      lightSettings.color = evt.settings.color;
      this.SetParameters(lightSettings, evt.time, evt.curve, evt.loop);
    };
  }

  private final func SetupLightSettings(inputData: EditableGameLightSettings, out outputData: gameLightSettings) -> Void {
    if inputData.modifyStrength {
      outputData.strength = inputData.strength;
    };
    if inputData.modifyIntensity {
      outputData.intensity = inputData.intensity;
    };
    if inputData.modifyRadius {
      outputData.radius = inputData.radius;
    };
    if inputData.modifyColor {
      outputData.color = inputData.color;
    };
    if inputData.modifyInnerAngle {
      outputData.innerAngle = inputData.innerAngle;
    };
    if inputData.modifyOuterAngle {
      outputData.outerAngle = inputData.outerAngle;
    };
  }

  protected cb func OnAdvanceChangeLight(evt: ref<AdvanceChangeLightEvent>) -> Bool {
    let fullComponentName: String;
    let lightSettings: gameLightSettings;
    if this.IsEnabled() {
      if IsNameValid(evt.settings.componentName) {
        fullComponentName = NameToString(this.GetName());
        if !StrContains(fullComponentName, NameToString(evt.settings.componentName)) {
          return false;
        };
      };
      lightSettings = this.GetCurrentSettings();
      this.SetupLightSettings(evt.settings, lightSettings);
      this.SetParameters(lightSettings, evt.time, evt.curve, evt.loop);
    };
  }

  protected cb func OnChangeCurveEvent(evt: ref<ChangeCurveEvent>) -> Bool {
    let lightSettings: gameLightSettings;
    if this.IsEnabled() {
      lightSettings = this.GetCurrentSettings();
      this.SetColor(new Color(0u, 0u, 0u, 0u));
      this.SetStrength(0.00);
      this.SetParameters(lightSettings, evt.time, evt.curve, evt.loop);
    };
  }

  public final static func ChangeLightSettingByRefs(lightRefs: array<ref<gameLightComponent>>, setting: ScriptLightSettings, opt inTime: Float, opt interpolationCurve: CName, opt loop: Bool) -> Void {
    let lightSettings: gameLightSettings;
    let i: Int32 = 0;
    while i < ArraySize(lightRefs) {
      if !IsDefined(lightRefs[i]) {
      } else {
        lightSettings = lightRefs[i].GetCurrentSettings();
        lightSettings.strength = setting.strength;
        lightSettings.color = setting.color;
        lightRefs[i].SetParameters(lightSettings, inTime, interpolationCurve, loop);
      };
      i += 1;
    };
  }

  public final static func ChangeAllLightsSettings(owner: wref<GameObject>, settings: ScriptLightSettings, opt time: Float, opt curve: CName, opt loop: Bool) -> Void {
    let evt: ref<ChangeLightEvent> = new ChangeLightEvent();
    evt.settings = settings;
    evt.time = time;
    evt.curve = curve;
    evt.loop = loop;
    owner.QueueEvent(evt);
  }
}
