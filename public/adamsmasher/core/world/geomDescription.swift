
public native class GeometryDescriptionQuery extends IScriptable {

  public native let refPosition: Vector4;

  public native let refDirection: Vector4;

  public native let refUp: Vector4;

  public native let primitiveDimension: Vector4;

  public native let primitiveRotation: Quaternion;

  public native let maxDistance: Float;

  public native let maxExtent: Float;

  public native let raycastStartDistance: Float;

  public native let probingPrecision: Float;

  public native let probingMaxDistanceDiff: Float;

  public native let maxProbes: Uint32;

  public native let probeDimensions: Vector4;

  public native let filter: QueryFilter;

  public native let flags: Uint32;

  public final func AddFlag(flag: worldgeometryDescriptionQueryFlags) -> Void {
    this.flags = Cast(Cast(this.flags) | EnumInt(flag));
  }

  public final func RemoveFlag(flag: worldgeometryDescriptionQueryFlags) -> Void {
    let notFlag: Uint64 = ~EnumInt(flag);
    this.flags = Cast(Cast(this.flags) & notFlag);
  }

  public final func TestFlag(flag: worldgeometryDescriptionQueryFlags) -> Bool {
    return (Cast(this.flags) & EnumInt(flag)) != 0u;
  }
}
