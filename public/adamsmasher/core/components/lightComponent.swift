
public native class LightComponent extends IVisualComponent {

  public final native func SetTemperature(temperature: Float) -> Void;

  public final native func SetColor(color: Color) -> Void;

  public final native func SetRadius(radius: Float) -> Void;

  public final native func SetIntensity(intensity: Float) -> Void;

  public final native func SetFlickerParams(strength: Float, period: Float, offset: Float) -> Void;

  protected cb func OnForceFlicker(evt: ref<FlickerEvent>) -> Bool {
    this.SetFlickerParams(evt.strength, evt.duration, evt.offset);
  }

  protected cb func OnToggleLight(evt: ref<ToggleLightEvent>) -> Bool {
    this.Toggle(evt.toggle);
  }

  protected cb func OnToggleLightByName(evt: ref<ToggleLightByNameEvent>) -> Bool {
    let fullComponentName: String = NameToString(this.GetName());
    if StrContains(fullComponentName, NameToString(evt.componentName)) {
      this.Toggle(evt.toggle);
    };
  }
}
