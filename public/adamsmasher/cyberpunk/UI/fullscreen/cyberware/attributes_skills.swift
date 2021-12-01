
public class CyberwareAttributesSkills extends inkGameController {

  protected edit let m_attributes: CyberwareAttributes_ContainersStruct;

  protected edit let m_resistances: CyberwareAttributes_ResistancesStruct;

  protected edit let m_levelUpPoints: inkTextRef;

  private let m_uiBlackboard: wref<IBlackboard>;

  private let m_playerPuppet: wref<PlayerPuppet>;

  private let m_devPoints: Int32;

  private let m_OnAttributesChangeCallback: ref<CallbackHandle>;

  private let m_OnDevelopmentPointsChangeCallback: ref<CallbackHandle>;

  private let m_OnProficiencyChangeCallback: ref<CallbackHandle>;

  private let m_OnMaxHealthChangedCallback: ref<CallbackHandle>;

  private let m_OnPhysicalResistanceChangedCallback: ref<CallbackHandle>;

  private let m_OnThermalResistanceChangedCallback: ref<CallbackHandle>;

  private let m_OnEnergyResistanceChangedCallback: ref<CallbackHandle>;

  private let m_OnChemicalResistanceChangedCallback: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let requestStatsEvent: ref<RequestStats>;
    this.m_playerPuppet = GameInstance.GetPlayerSystem(this.GetPlayerControlledObject().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    if IsDefined(this.m_uiBlackboard) {
      this.m_OnAttributesChangeCallback = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerStats.Attributes, this, n"OnAttributesChange");
      this.m_OnDevelopmentPointsChangeCallback = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerStats.DevelopmentPoints, this, n"OnDevelopmentPointsChange");
      this.m_OnProficiencyChangeCallback = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerStats.Proficiency, this, n"OnProficiencyChange");
      this.m_OnMaxHealthChangedCallback = this.m_uiBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.MaxHealth, this, n"OnSomeResistanceChanged");
      this.m_OnPhysicalResistanceChangedCallback = this.m_uiBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.PhysicalResistance, this, n"OnSomeResistanceChanged");
      this.m_OnThermalResistanceChangedCallback = this.m_uiBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.ThermalResistance, this, n"OnSomeResistanceChanged");
      this.m_OnEnergyResistanceChangedCallback = this.m_uiBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.EnergyResistance, this, n"OnSomeResistanceChanged");
      this.m_OnChemicalResistanceChangedCallback = this.m_uiBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.ChemicalResistance, this, n"OnSomeResistanceChanged");
    };
    this.m_attributes.logicBody = inkWidgetRef.GetController(this.m_attributes.widgetBody) as CyberwareAttributes_Logic;
    this.m_attributes.logicCool = inkWidgetRef.GetController(this.m_attributes.widgetCool) as CyberwareAttributes_Logic;
    this.m_attributes.logicInt = inkWidgetRef.GetController(this.m_attributes.widgetInt) as CyberwareAttributes_Logic;
    this.m_attributes.logicRef = inkWidgetRef.GetController(this.m_attributes.widgetRef) as CyberwareAttributes_Logic;
    this.m_attributes.logicTech = inkWidgetRef.GetController(this.m_attributes.widgetTech) as CyberwareAttributes_Logic;
    inkWidgetRef.Get(this.m_resistances.widgetHealth).RegisterToCallback(n"OnButtonStateChanged", this, n"OnResistancesHover");
    inkWidgetRef.Get(this.m_resistances.widgetPhysical).RegisterToCallback(n"OnButtonStateChanged", this, n"OnResistancesHover");
    inkWidgetRef.Get(this.m_resistances.widgetThermal).RegisterToCallback(n"OnButtonStateChanged", this, n"OnResistancesHover");
    inkWidgetRef.Get(this.m_resistances.widgetEMP).RegisterToCallback(n"OnButtonStateChanged", this, n"OnResistancesHover");
    inkWidgetRef.Get(this.m_resistances.widgetChemical).RegisterToCallback(n"OnButtonStateChanged", this, n"OnResistancesHover");
    this.SyncWithPlayerDevSystem();
    requestStatsEvent = new RequestStats();
    this.m_playerPuppet.QueueEvent(requestStatsEvent);
    inkWidgetRef.Get(this.m_resistances.resistanceTooltip).SetVisible(false);
    (this.GetWidget(inkWidgetPath.Build(n"temp_paperdoll")) as inkVideo).Play();
  }

  private final func SyncWithPlayerDevSystem() -> Void {
    this.SyncProficiencies();
    this.SyncStats();
    this.SyncDevPoints();
  }

  private final func SyncProficiencies() -> Void;

  private final func HelperGetStatText(currStatType: gamedataStatType, statsSystem: ref<StatsSystem>) -> String {
    let currInt: Int32 = Cast(statsSystem.GetStatValue(Cast(this.m_playerPuppet.GetEntityID()), currStatType));
    return IntToString(currInt);
  }

  private final func SyncStats() -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_playerPuppet.GetGame());
    let currText: wref<inkText> = inkCompoundRef.GetWidget(this.m_resistances.widgetHealth, inkWidgetPath.Build(n"textVert", n"resistanceText")) as inkText;
    currText.SetText(this.HelperGetStatText(gamedataStatType.Health, statsSystem));
    currText = inkCompoundRef.GetWidget(this.m_resistances.widgetPhysical, inkWidgetPath.Build(n"textVert", n"resistanceText")) as inkText;
    currText.SetText(this.HelperGetStatText(gamedataStatType.PhysicalResistance, statsSystem));
    currText = inkCompoundRef.GetWidget(this.m_resistances.widgetChemical, inkWidgetPath.Build(n"textVert", n"resistanceText")) as inkText;
    currText.SetText(this.HelperGetStatText(gamedataStatType.ChemicalResistance, statsSystem));
    currText = inkCompoundRef.GetWidget(this.m_resistances.widgetThermal, inkWidgetPath.Build(n"textVert", n"resistanceText")) as inkText;
    currText.SetText(this.HelperGetStatText(gamedataStatType.ThermalResistance, statsSystem));
    currText = inkCompoundRef.GetWidget(this.m_resistances.widgetEMP, inkWidgetPath.Build(n"textVert", n"resistanceText")) as inkText;
    currText.SetText(this.HelperGetStatText(gamedataStatType.ElectricResistance, statsSystem));
    (inkWidgetRef.GetController(this.m_attributes.widgetBody) as CyberwareAttributes_Logic).SetAttributeValue(this.HelperGetStatText(gamedataStatType.Strength, statsSystem));
    (inkWidgetRef.GetController(this.m_attributes.widgetCool) as CyberwareAttributes_Logic).SetAttributeValue(this.HelperGetStatText(gamedataStatType.Cool, statsSystem));
    (inkWidgetRef.GetController(this.m_attributes.widgetInt) as CyberwareAttributes_Logic).SetAttributeValue(this.HelperGetStatText(gamedataStatType.Intelligence, statsSystem));
    (inkWidgetRef.GetController(this.m_attributes.widgetRef) as CyberwareAttributes_Logic).SetAttributeValue(this.HelperGetStatText(gamedataStatType.Reflexes, statsSystem));
    (inkWidgetRef.GetController(this.m_attributes.widgetTech) as CyberwareAttributes_Logic).SetAttributeValue(this.HelperGetStatText(gamedataStatType.TechnicalAbility, statsSystem));
  }

  protected cb func OnSomeResistanceChanged(value: Int32) -> Bool {
    this.SyncStats();
  }

  private final func SyncDevPoints() -> Void {
    let devSystem: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_playerPuppet.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    this.m_devPoints = devSystem.GetDevPoints(this.m_playerPuppet, gamedataDevelopmentPointType.Attribute);
    inkTextRef.SetText(this.m_levelUpPoints, IntToString(this.m_devPoints));
  }

  protected cb func OnResistancesHover(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    let isHovering: Bool = Equals(oldState, inkEButtonState.Normal) && Equals(newState, inkEButtonState.Hover);
    inkWidgetRef.Get(this.m_resistances.resistanceTooltip).SetVisible(isHovering);
  }

  private final func OnSpendPoints(e: ref<inkPointerEvent>) -> Void {
    let requestUpdateEvent: ref<RequestStats>;
    let requestBuyStatsEvent: ref<RequestBuyAttribute> = new RequestBuyAttribute();
    let widgetTarget: wref<inkWidget> = e.GetTarget();
    if widgetTarget == inkWidgetRef.Get(this.m_attributes.widgetRef) {
      requestBuyStatsEvent.type = gamedataStatType.Reflexes;
    } else {
      if widgetTarget == inkWidgetRef.Get(this.m_attributes.widgetBody) {
        requestBuyStatsEvent.type = gamedataStatType.Strength;
      } else {
        if widgetTarget == inkWidgetRef.Get(this.m_attributes.widgetTech) {
          requestBuyStatsEvent.type = gamedataStatType.TechnicalAbility;
        } else {
          if widgetTarget == inkWidgetRef.Get(this.m_attributes.widgetInt) {
            requestBuyStatsEvent.type = gamedataStatType.Intelligence;
          } else {
            if widgetTarget == inkWidgetRef.Get(this.m_attributes.widgetCool) {
              requestBuyStatsEvent.type = gamedataStatType.Cool;
            } else {
              requestBuyStatsEvent.type = gamedataStatType.Invalid;
            };
          };
        };
      };
    };
    this.m_playerPuppet.QueueEvent(requestBuyStatsEvent);
    requestUpdateEvent = new RequestStats();
    this.m_playerPuppet.QueueEvent(requestUpdateEvent);
  }

  protected cb func OnAttributesChange(value: Variant) -> Bool {
    let currName: gamedataStatType;
    let currValue: String;
    let attributes: array<SAttribute> = FromVariant(value);
    let i: Int32 = 0;
    while i < ArraySize(attributes) {
      currName = attributes[i].attributeName;
      currValue = IntToString(attributes[i].value);
      if Equals(currName, gamedataStatType.Strength) {
        this.m_attributes.logicBody.SetAttributeValue(currValue);
      } else {
        if Equals(currName, gamedataStatType.Reflexes) {
          this.m_attributes.logicRef.SetAttributeValue(currValue);
        } else {
          if Equals(currName, gamedataStatType.TechnicalAbility) {
            this.m_attributes.logicTech.SetAttributeValue(currValue);
          } else {
            if Equals(currName, gamedataStatType.Intelligence) {
              this.m_attributes.logicInt.SetAttributeValue(currValue);
            } else {
              if Equals(currName, gamedataStatType.Cool) {
                this.m_attributes.logicCool.SetAttributeValue(currValue);
              };
            };
          };
        };
      };
      i += 1;
    };
  }

  protected cb func OnDevelopmentPointsChange(value: Variant) -> Bool {
    let developmentPoints: array<SDevelopmentPoints> = FromVariant(value);
    let i: Int32 = 0;
    while i < ArraySize(developmentPoints) {
      if Equals(developmentPoints[i].type, gamedataDevelopmentPointType.Attribute) {
        this.m_devPoints = developmentPoints[i].unspent;
        inkTextRef.SetText(this.m_levelUpPoints, IntToString(developmentPoints[i].unspent));
        return true;
      };
      i += 1;
    };
  }

  protected cb func OnProficiencyChange(value: Variant) -> Bool;
}

public class CyberwareAttributes_Logic extends inkLogicController {

  protected edit let m_textValue: inkTextRef;

  protected edit let m_buttonRef: inkWidgetRef;

  protected edit let m_tooltipRef: inkWidgetRef;

  protected edit let m_connectorRef: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_tooltipRef, false);
    inkWidgetRef.SetVisible(this.m_connectorRef, false);
    inkWidgetRef.RegisterToCallback(this.m_buttonRef, n"OnHoverOver", this, n"OnButtonHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonRef, n"OnHoverOut", this, n"OnButtonHoverOut");
  }

  protected cb func OnButtonHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_tooltipRef, true);
    inkWidgetRef.SetVisible(this.m_connectorRef, true);
  }

  protected cb func OnButtonHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_tooltipRef, false);
    inkWidgetRef.SetVisible(this.m_connectorRef, false);
  }

  public final func SetAttributeValue(value: String) -> Void {
    let currGraphic: wref<inkImage>;
    inkTextRef.SetText(this.m_textValue, value);
    currGraphic = (inkWidgetRef.Get(this.m_buttonRef) as inkCanvas).GetWidget(inkWidgetPath.Build(n"mainRotate", n"graphic")) as inkImage;
    if currGraphic != null {
      currGraphic.SetTexturePart(StringToName("barcode_" + value));
    };
  }
}
