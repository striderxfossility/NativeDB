
public final native class gameDoorComponent extends IComponent {

  public final native func IsInteractible() -> Bool;

  public final native func IsAutomatic() -> Bool;

  public final native func IsPhysical() -> Bool;

  public final native func IsOpen() -> Bool;

  public final native func IsLocked() -> Bool;

  public final native func IsSealed() -> Bool;

  public final native func IsOffline() -> Bool;

  public final native func GetOpeningSpeed() -> Float;

  public final native func SetOpen(newVal: Bool) -> Bool;

  public final native func SetLocked(newVal: Bool) -> Bool;

  public final native func SetSealed(newVal: Bool) -> Bool;

  public final native func SetOffline(newVal: Bool) -> Bool;

  public final func ToggleOpen() -> Void {
    this.SetOpen(!this.IsOpen());
  }
}
