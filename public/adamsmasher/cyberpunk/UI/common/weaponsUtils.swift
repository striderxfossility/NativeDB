
public class WeaponsUtils extends IScriptable {

  public final static func GetDamageTypeIcon(damageType: gamedataDamageType) -> CName {
    switch damageType {
      case gamedataDamageType.Chemical:
        return n"icon_chemical";
      case gamedataDamageType.Electric:
        return n"icon_emp";
      case gamedataDamageType.Physical:
        return n"icon_physical";
      case gamedataDamageType.Thermal:
        return n"icon_thermal";
    };
    return n"";
  }
}
