
public class RipperdocFilterToggleController extends ToggleController {

  public func GetLabelKey() -> String {
    let enumValue: RipperdocFilter = IntEnum(this.m_data);
    switch enumValue {
      case RipperdocFilter.All:
        return "UI-Filters-AllItems";
      case RipperdocFilter.Player:
        return "UI-Filters-PlayerItems";
      case RipperdocFilter.Vendor:
        return "UI-Filters-VendorItems";
    };
    return "UI-Filters-AllItems";
  }

  public func GetIcon() -> String {
    let enumValue: RipperdocFilter = IntEnum(this.m_data);
    switch enumValue {
      case RipperdocFilter.All:
        return "UIIcon.Filter_AllItems";
      case RipperdocFilter.Player:
        return "UIIcon.Filter_PlayerItems";
      case RipperdocFilter.Vendor:
        return "UIIcon.Filter_VendorItems";
    };
    return "UIIcon.Filter_AllItems";
  }
}
