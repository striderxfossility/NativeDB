
public class CharacterCreationAttributeData extends IScriptable {

  public let label: String;

  public let desc: String;

  public let value: Int32;

  public let attribute: gamedataStatType;

  public let icon: CName;

  public let maxValue: Int32;

  public let minValue: Int32;

  public let maxed: Bool;

  public let atMinimum: Bool;

  public final func SetValue(val: Int32) -> Void {
    this.value = val;
  }

  public final func SetMaxed(val: Bool) -> Void {
    this.maxed = val;
  }

  public final func SetAtMinimum(val: Bool) -> Void {
    this.atMinimum = val;
  }
}

public class characterCreationStatsAttributeBtn extends inkLogicController {

  public edit let m_value: inkTextRef;

  public edit let m_label: inkTextRef;

  public edit let m_addBtn: inkWidgetRef;

  public edit let m_addBtnhitArea: inkWidgetRef;

  public edit let m_minusBtn: inkWidgetRef;

  public edit let m_minusBtnhitArea: inkWidgetRef;

  public edit let m_minMaxLabel: inkWidgetRef;

  public edit let m_minMaxLabelText: inkTextRef;

  public edit let m_minusBtnNONE: inkWidgetRef;

  public edit let m_addBtnNONE: inkWidgetRef;

  public let data: ref<CharacterCreationAttributeData>;

  public let animating: Bool;

  public let m_minusEnabled: Bool;

  public let m_addEnabled: Bool;

  public let m_maxed: Bool;

  private let m_addBtnState: AttributeButtonState;

  private let m_minusBtnState: AttributeButtonState;

  private let m_state: AttributeButtonState;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_addBtnhitArea, n"OnRelease", this, n"OnAdd");
    inkWidgetRef.RegisterToCallback(this.m_minusBtnhitArea, n"OnRelease", this, n"OnMinus");
    this.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnHitAreaOnHoverOver");
    this.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnHitAreaOnHoverOut");
    this.m_addEnabled = true;
    this.m_minusEnabled = true;
    this.m_state = AttributeButtonState.Default;
  }

  protected cb func OnUninitialize() -> Bool;

  public final func Refresh() -> Void {
    inkTextRef.SetText(this.m_value, ToString(this.data.value));
    this.animating = false;
    this.RefreshVisibility();
  }

  public final func Increment() -> Void {
    if this.animating {
      return;
    };
    this.animating = true;
    this.CallCustomCallback(n"OnValueIncremented");
  }

  public final func Decrement() -> Void {
    if this.animating {
      return;
    };
    this.animating = true;
    this.CallCustomCallback(n"OnValueDecremented");
  }

  public final func SetData(attribute: gamedataStatType, value: Int32) -> Void {
    this.data = new CharacterCreationAttributeData();
    let str: String = EnumValueToString("gamedataStatType", Cast(EnumInt(attribute)));
    let record: ref<UICharacterCreationAttribute_Record> = TweakDBInterface.GetUICharacterCreationAttributeRecord(TDBID.Create("UICharacterCreationGeneral." + str));
    this.data.value = value;
    this.data.attribute = attribute;
    this.data.icon = record.IconPath();
    this.data.desc = record.Description();
    let statsRecord: ref<Stat_Record> = record.Attribute();
    this.data.label = statsRecord.LocalizedName();
    inkTextRef.SetText(this.m_label, this.data.label);
  }

  private final func RefreshVisibility() -> Void {
    if this.m_minusEnabled {
      inkWidgetRef.SetVisible(this.m_minusBtnNONE, false);
      inkWidgetRef.SetOpacity(this.m_minusBtn, 1.00);
    } else {
      inkWidgetRef.SetVisible(this.m_minusBtnNONE, true);
      inkWidgetRef.SetOpacity(this.m_minusBtn, 0.30);
    };
    if this.m_addEnabled {
      inkWidgetRef.SetVisible(this.m_addBtnNONE, false);
      inkWidgetRef.SetOpacity(this.m_addBtn, 1.00);
    } else {
      inkWidgetRef.SetVisible(this.m_addBtnNONE, true);
      inkWidgetRef.SetOpacity(this.m_addBtn, 0.30);
    };
  }

  protected cb func OnMinus(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      if this.m_minusEnabled {
        this.PlaySound(n"MapPin", n"OnEnable");
        this.Decrement();
      } else {
        this.SetCursorContext(n"InvalidAction");
        this.PlaySound(n"MapPin", n"OnDisable");
      };
    };
  }

  protected cb func OnAdd(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      if this.m_addEnabled {
        this.PlaySound(n"MapPin", n"OnCreate");
        this.Increment();
      } else {
        this.SetCursorContext(n"InvalidAction");
        this.PlaySound(n"MapPin", n"OnDisable");
      };
    };
  }

  protected cb func OnHitAreaOnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"SemiHover");
    this.CallCustomCallback(n"OnBtnHoverOver");
  }

  protected cb func OnHitAreaOnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
    this.CallCustomCallback(n"OnBtnHoverOut");
  }

  public final func ManageBtnVisibility(addEnabled: Bool, minusEnabled: Bool) -> Void {
    this.m_addEnabled = addEnabled;
    this.m_minusEnabled = minusEnabled;
    this.RefreshVisibility();
  }

  public final func ManageLabel(atMin: Bool, atMax: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_minMaxLabel, atMin || atMax);
    if atMax {
      inkTextRef.SetText(this.m_minMaxLabelText, "LocKey#42807");
    } else {
      if atMin {
        inkTextRef.SetText(this.m_minMaxLabelText, "LocKey#42808");
      };
    };
  }
}
