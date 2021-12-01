
public native struct Box {

  public native let Min: Vector4;

  public native let Max: Vector4;

  public final static func GetSize(box: Box) -> Vector4 {
    return box.Max - box.Min;
  }

  public final static func GetExtents(box: Box) -> Vector4 {
    return (box.Max - box.Min) * 0.50;
  }

  public final static func GetRange(box: Box) -> Float {
    let size: Vector4 = Box.GetExtents(box);
    if size.X > size.Y && size.X > size.Z {
      return size.X;
    };
    if size.Y > size.Z {
      return size.Y;
    };
    return size.Z;
  }
}
