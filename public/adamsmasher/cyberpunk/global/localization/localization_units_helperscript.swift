
public class UnitsLocalizationHelper extends IScriptable {

  public final static func LocalizeDistance(distance: Float) -> String {
    if distance > 1000.00 {
      return FloatToStringPrec(distance / 1000.00, 1) + "KM";
    };
    return FloatToStringPrec(distance, 0) + "M";
  }
}
