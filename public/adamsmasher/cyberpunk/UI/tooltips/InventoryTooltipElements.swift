
public class TooltipSpecialAbilityList extends inkLogicController {

  private edit let m_libraryItemName: CName;

  private edit let m_container: inkCompoundRef;

  private let m_itemsList: array<wref<inkWidget>>;

  private let m_data: array<InventoryItemAbility>;

  private let m_qualityName: CName;

  public final func SetData(qualityState: CName, data: array<InventoryItemAbility>) -> Void {
    this.m_qualityName = qualityState;
    this.m_data = data;
    this.UpdateLayout();
  }

  public final func ClearData(toLeave: Int32) -> Void {
    let statItem: wref<inkWidget>;
    while ArraySize(this.m_itemsList) > toLeave {
      statItem = ArrayPop(this.m_itemsList);
      inkCompoundRef.RemoveChild(this.m_container, statItem);
    };
  }

  private final func UpdateLayout() -> Void {
    let abilityItem: wref<TooltipSpecialAbilityDisplay>;
    let i: Int32;
    let widget: wref<inkWidget>;
    let dataCount: Int32 = ArraySize(this.m_data);
    this.ClearData(dataCount);
    while ArraySize(this.m_itemsList) < dataCount {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), this.m_libraryItemName);
      widget.SetStyle(inkWidgetRef.GetStylePath(this.m_container));
      ArrayPush(this.m_itemsList, widget);
    };
    i = 0;
    while i < dataCount {
      widget = this.m_itemsList[i];
      abilityItem = widget.GetController() as TooltipSpecialAbilityDisplay;
      abilityItem.Setup(this.m_qualityName, this.m_data[i]);
      i += 1;
    };
  }

  public final func UpdateVisibility(force: Bool) -> Void {
    this.GetRootWidget().SetVisible(force);
  }

  public final func UpdateVisibility() -> Void {
    this.GetRootWidget().SetVisible(ArraySize(this.m_itemsList) > 0);
  }
}

public class TooltipSpecialAbilityDisplay extends inkLogicController {

  private edit let m_AbilityIcon: inkImageRef;

  private edit let m_AbilityDescription: inkTextRef;

  private edit let m_QualityRoot: inkWidgetRef;

  public final func Setup(qualityName: CName, data: InventoryItemAbility) -> Void {
    inkImageRef.SetTexturePart(this.m_AbilityIcon, data.IconPath);
    if inkWidgetRef.IsValid(this.m_AbilityDescription) {
      inkTextRef.SetText(this.m_AbilityDescription, data.Description);
    };
    if inkWidgetRef.IsValid(this.m_QualityRoot) {
      inkWidgetRef.SetState(this.m_QualityRoot, qualityName);
    };
  }
}

public class InventoryItemAttachmentsList extends inkLogicController {

  private edit let m_libraryItemName: CName;

  private edit let m_container: inkCompoundRef;

  private let m_itemsList: array<wref<inkWidget>>;

  private let m_data: array<CName>;

  public final func SetData(data: array<CName>) -> Void {
    this.m_data = data;
    this.UpdateLayout();
  }

  public final func ClearData(toLeave: Int32) -> Void {
    let statItem: wref<inkWidget>;
    while ArraySize(this.m_itemsList) > toLeave {
      statItem = ArrayPop(this.m_itemsList);
      inkCompoundRef.RemoveChild(this.m_container, statItem);
    };
  }

  private final func UpdateLayout() -> Void {
    let attachmentItem: wref<InventoryItemAttachmentDisplay>;
    let i: Int32;
    let widget: wref<inkWidget>;
    let dataCount: Int32 = ArraySize(this.m_data);
    this.ClearData(dataCount);
    while ArraySize(this.m_itemsList) < dataCount {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_container), this.m_libraryItemName);
      widget.SetStyle(inkWidgetRef.GetStylePath(this.m_container));
      ArrayPush(this.m_itemsList, widget);
    };
    i = 0;
    while i < dataCount {
      widget = this.m_itemsList[i];
      attachmentItem = widget.GetController() as InventoryItemAttachmentDisplay;
      attachmentItem.Setup(IsNameValid(this.m_data[i]), this.m_data[i]);
      i += 1;
    };
  }

  public final func UpdateVisibility(force: Bool) -> Void {
    this.GetRootWidget().SetVisible(force);
  }

  public final func UpdateVisibility() -> Void {
    this.GetRootWidget().SetVisible(ArraySize(this.m_itemsList) > 0);
  }
}

public class InventoryItemStatList extends inkLogicController {

  public edit let m_libraryItemName: CName;

  private let m_container: wref<inkCompoundWidget>;

  private let m_data: array<InventoryTooltipData_StatData>;

  private let m_itemsList: array<wref<inkWidget>>;

  protected cb func OnInitialize() -> Bool {
    this.m_container = this.GetRootWidget() as inkCompoundWidget;
  }

  public final func SetData(data: array<InventoryTooltipData_StatData>) -> Void {
    this.m_data = data;
    this.UpdateLayout();
  }

  public final func ClearData(toLeave: Int32) -> Void {
    let statItem: wref<inkWidget>;
    while ArraySize(this.m_itemsList) > toLeave {
      statItem = ArrayPop(this.m_itemsList);
      this.m_container.RemoveChild(statItem);
    };
  }

  private final func UpdateLayout() -> Void {
    let i: Int32;
    let statItem: wref<inkWidget>;
    let statItemCtrl: wref<InventoryItemStatItem>;
    let dataCount: Int32 = ArraySize(this.m_data);
    this.ClearData(dataCount);
    while ArraySize(this.m_itemsList) < dataCount {
      statItem = this.SpawnFromLocal(this.m_container, this.m_libraryItemName);
      statItem.SetStyle(this.m_container.GetStylePath());
      ArrayPush(this.m_itemsList, statItem);
    };
    i = 0;
    while i < dataCount {
      statItem = this.m_itemsList[i];
      statItemCtrl = statItem.GetController() as InventoryItemStatItem;
      statItemCtrl.SetData(this.m_data[i]);
      i += 1;
    };
  }

  public final func UpdateVisibility(force: Bool) -> Void {
    this.GetRootWidget().SetVisible(force);
  }

  public final func UpdateVisibility() -> Void {
    this.GetRootWidget().SetVisible(ArraySize(this.m_itemsList) > 0);
  }
}

public class InventoryItemStatItem extends inkLogicController {

  private edit let m_labelText: inkTextRef;

  private edit let m_valueText: inkTextRef;

  private edit let m_differenceBarRef: inkWidgetRef;

  private edit let m_diffrenceArrowIndicatorRef: inkWidgetRef;

  public let m_root: wref<inkWidget>;

  public let m_differenceBar: wref<StatisticDifferenceBarController>;

  @default(InventoryItemStatItem, worse)
  private edit let m_negativeState: CName;

  @default(InventoryItemStatItem, better)
  private edit let m_positiveState: CName;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    if inkWidgetRef.IsValid(this.m_differenceBarRef) {
      this.m_differenceBar = inkWidgetRef.GetController(this.m_differenceBarRef) as StatisticDifferenceBarController;
    };
  }

  public final func SetData(data: InventoryTooltipData_StatData) -> Void {
    let stateName: CName = inkWidget.DefaultState();
    let diffValue: Int32 = data.diffValue;
    if diffValue != 0 {
      stateName = diffValue > 0 ? this.m_positiveState : this.m_negativeState;
    };
    if NotEquals(data.state, EInventoryDataStatDisplayType.Value) {
      inkTextRef.SetText(this.m_valueText, IntToString(data.currentValue));
      if IsDefined(this.m_differenceBar) {
        this.m_differenceBar.Setup(data);
        this.m_differenceBar.GetRootWidget().SetVisible(true);
      };
    } else {
      if IsDefined(this.m_differenceBar) {
        this.m_differenceBar.GetRootWidget().SetVisible(false);
      };
      inkTextRef.SetText(this.m_valueText, IntToString(data.currentValue));
    };
    if IsDefined(inkWidgetRef.Get(this.m_diffrenceArrowIndicatorRef)) {
      if diffValue == 0 {
        inkWidgetRef.SetVisible(this.m_diffrenceArrowIndicatorRef, false);
      } else {
        inkWidgetRef.SetVisible(this.m_diffrenceArrowIndicatorRef, true);
        if Equals(stateName, this.m_positiveState) {
          inkWidgetRef.SetRotation(this.m_diffrenceArrowIndicatorRef, 30.00);
        } else {
          inkWidgetRef.SetRotation(this.m_diffrenceArrowIndicatorRef, 210.00);
        };
      };
    };
    inkTextRef.SetText(this.m_labelText, data.statName);
    this.m_root.SetState(stateName);
  }
}

public class StatisticDifferenceBarController extends inkLogicController {

  private edit let m_filled: inkWidgetRef;

  private edit let m_difference: inkWidgetRef;

  private edit let m_empty: inkWidgetRef;

  public final func Setup(dataObject: InventoryTooltipData_StatData) -> Void {
    let rMax: Float = Cast(dataObject.maxStatValue);
    let rMin: Float = Cast(dataObject.minStatValue);
    let rDiff: Float = Cast(dataObject.diffValue);
    let rValue: Float = Cast(dataObject.currentValue);
    let size: Float = rMax - rMin;
    let filled: Float = MinF(rValue, rValue - rDiff) / size;
    let difference: Float = AbsF(rDiff) / size;
    let empty: Float = 1.00 - filled - difference;
    inkWidgetRef.SetSizeCoefficient(this.m_filled, filled);
    inkWidgetRef.SetSizeCoefficient(this.m_difference, difference);
    inkWidgetRef.SetSizeCoefficient(this.m_empty, empty);
  }
}

public class DamageTypeIndicator extends inkLogicController {

  private edit let m_DamageIconRef: inkImageRef;

  private edit let m_DamageTypeLabelRef: inkTextRef;

  public final func Setup(damageType: gamedataDamageType) -> Void {
    let damageTypeString: String;
    let iconRef: ref<UIIconReference>;
    if Equals(damageType, gamedataDamageType.Invalid) {
      this.GetRootWidget().SetVisible(false);
    } else {
      damageTypeString = ToString(damageType);
      inkTextRef.SetLetterCase(this.m_DamageTypeLabelRef, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_DamageTypeLabelRef, damageTypeString);
      iconRef = new UIIconReference();
      iconRef.iconID = UIItemsHelper.GetTweakDBIDForDamageType(damageType);
      inkImageRef.RequestSetImage(this.m_DamageIconRef, iconRef);
      this.GetRootWidget().SetState(UIItemsHelper.GetStateNameForDamageType(damageType));
      this.GetRootWidget().SetVisible(true);
    };
  }
}
