
public class TooltipProvider extends inkLogicController {

  private let m_TooltipsData: array<ref<ATooltipData>>;

  private let m_visible: Bool;

  public final func ClearTooltipData() -> Void {
    ArrayClear(this.m_TooltipsData);
  }

  public final func PushData(data: ref<ATooltipData>) -> Void {
    ArrayPush(this.m_TooltipsData, data);
  }

  public final func AddData(data: ref<ATooltipData>) -> Void {
    ArrayInsert(this.m_TooltipsData, 0, data);
  }

  public final func RefreshTooltips() -> Void {
    let refreshTooltipEvent: ref<RefreshTooltipEvent> = new RefreshTooltipEvent();
    refreshTooltipEvent.widget = this.GetRootWidget();
    this.QueueEvent(refreshTooltipEvent);
  }

  public final func InvalidateHidden() -> Void {
    let invalidateHiddenEvent: ref<InvalidateTooltipHiddenStateEvent> = new InvalidateTooltipHiddenStateEvent();
    invalidateHiddenEvent.widget = this.GetRootWidget();
    this.QueueEvent(invalidateHiddenEvent);
  }

  public final func GetIdentifiedTooltipOwner(index: Int32) -> EntityID {
    let identifiedTooltip: ref<IdentifiedWrappedTooltipData>;
    if this.HasTooltipData(index) {
      identifiedTooltip = this.m_TooltipsData[index] as IdentifiedWrappedTooltipData;
      if IsDefined(identifiedTooltip) {
        return identifiedTooltip.m_tooltipOwner;
      };
      return EMPTY_ENTITY_ID();
    };
    return EMPTY_ENTITY_ID();
  }

  public final func HasTooltipData(index: Int32) -> Bool {
    return index < ArraySize(this.m_TooltipsData);
  }

  public final func HasAnyTooltipData() -> Bool {
    return ArraySize(this.m_TooltipsData) > 0;
  }

  public final func GetTooltipData(index: Int32) -> ref<ATooltipData> {
    if this.HasTooltipData(index) {
      return this.m_TooltipsData[index];
    };
    return null;
  }

  public final func GetTooltipsData() -> array<ref<ATooltipData>> {
    return this.m_TooltipsData;
  }

  public final func IsVisible() -> Bool {
    return this.m_visible;
  }

  public final func SetVisible(visible: Bool) -> Void {
    this.m_visible = visible;
  }
}
