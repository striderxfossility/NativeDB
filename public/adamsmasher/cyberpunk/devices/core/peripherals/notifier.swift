
public class ActionNotifier extends IScriptable {

  public let external: Bool;

  public let internal: Bool;

  public let failed: Bool;

  public final func SetInternalOnly() -> Void {
    this.external = false;
    this.internal = true;
  }

  public final func SetExternalOnly() -> Void {
    this.external = true;
    this.internal = false;
  }

  public final func SetAll() -> Void {
    this.external = true;
    this.internal = true;
  }

  public final func SetNone() -> Void {
    this.external = false;
    this.internal = false;
  }

  public final func SetFailed() -> Void {
    this.external = false;
    this.internal = false;
    this.failed = true;
  }

  public final func IsInternalOnly() -> Bool {
    return Equals(this.external, false) && Equals(this.internal, true);
  }

  public final func IsExternalOnly() -> Bool {
    return Equals(this.external, true) && Equals(this.internal, false);
  }

  public final func IsAll() -> Bool {
    return Equals(this.external, true) && Equals(this.internal, true);
  }

  public final func IsNone() -> Bool {
    return Equals(this.external, false) && Equals(this.internal, false);
  }

  public final func IsFailed() -> Bool {
    return Equals(this.failed, true);
  }
}
