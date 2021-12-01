
public class SingleCooldownManager extends inkLogicController {

  private edit let m_sprite: inkImageRef;

  private edit let m_spriteBg: inkImageRef;

  private edit let m_icon: inkImageRef;

  private edit let m_type: ECooldownGameControllerMode;

  private edit let m_name: inkTextRef;

  private edit let m_desc: inkTextRef;

  private edit let m_timeRemaining: inkTextRef;

  private edit let m_stackCount: inkTextRef;

  private edit let m_fill: inkRectangleRef;

  private edit let m_outroDuration: Float;

  private let m_fullSizeValue: Vector2;

  private let m_initialDuration: Float;

  private let m_state: ECooldownIndicatorState;

  private let m_pool: inkCompoundRef;

  private let m_grid: inkCompoundRef;

  private let m_currentAnimProxy: ref<inkAnimProxy>;

  private let m_buffData: UIBuffInfo;

  private let m_defaultTimeRemainingText: String;

  private let excludedStatusEffect: TweakDBID;

  @default(SingleCooldownManager, BaseStatusEffect.AlcoholDebuff)
  private let C_EXCLUDED_STATUS_EFFECT_NAME: String;

  public final func Init(pool: inkCompoundRef, grid: inkCompoundRef) -> Void {
    this.m_pool = pool;
    this.m_grid = grid;
    this.m_fullSizeValue = inkWidgetRef.GetSize(this.m_fill);
    this.m_state = ECooldownIndicatorState.Pooled;
    this.m_defaultTimeRemainingText = inkTextRef.GetText(this.m_timeRemaining);
    this.GetRootWidget().SetVisible(false);
  }

  public final func ActivateCooldown(buffData: UIBuffInfo) -> Void {
    let effectUIData: wref<StatusEffectUIData_Record>;
    let i: Int32;
    let textParams: ref<inkTextParams>;
    this.excludedStatusEffect = TDBID.Create(this.C_EXCLUDED_STATUS_EFFECT_NAME);
    this.m_buffData = buffData;
    let effect: wref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(this.m_buffData.buffID);
    if IsDefined(effect) && effect.GetID() != this.excludedStatusEffect {
      effectUIData = effect.UiData();
      if IsDefined(effectUIData) {
        this.GetRootWidget().SetVisible(true);
        if this.m_buffData.isBuff {
          this.GetRootWidget().SetState(n"Buff");
        } else {
          this.GetRootWidget().SetState(n"Debuff");
        };
        inkTextRef.SetText(this.m_name, effectUIData.DisplayName());
        inkTextRef.SetText(this.m_desc, effectUIData.Description());
        inkWidgetRef.SetVisible(this.m_desc, IsStringValid(effectUIData.Description()));
        if effectUIData.GetFloatValuesCount() > 0 || effectUIData.GetIntValuesCount() > 0 || effectUIData.GetNameValuesCount() > 0 {
          textParams = new inkTextParams();
          i = 0;
          while i < effectUIData.GetFloatValuesCount() {
            textParams.AddNumber("float_" + IntToString(i), effectUIData.GetFloatValuesItem(i));
            i += 1;
          };
          i = 0;
          while i < effectUIData.GetIntValuesCount() {
            textParams.AddNumber("int_" + IntToString(i), effectUIData.GetIntValuesItem(i));
            i += 1;
          };
          i = 0;
          while i < effectUIData.GetNameValuesCount() {
            textParams.AddString("name_" + IntToString(i), GetLocalizedText(NameToString(effectUIData.GetNameValuesItem(i))));
            i += 1;
          };
          inkTextRef.SetTextParameters(this.m_desc, textParams);
        };
        this.SetTimeRemaining(this.m_buffData.timeRemaining);
        this.SetStackCount(Cast(this.m_buffData.stackCount));
        if Equals(this.m_type, ECooldownGameControllerMode.COOLDOWNS) {
          InkImageUtils.RequestSetImage(this, this.m_spriteBg, "UIIcon." + effectUIData.IconPath());
          InkImageUtils.RequestSetImage(this, this.m_sprite, "UIIcon." + effectUIData.IconPath());
        } else {
          InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + effectUIData.IconPath());
        };
      };
    };
    this.m_state = ECooldownIndicatorState.Intro;
    this.m_initialDuration = this.m_buffData.timeRemaining;
    if this.m_initialDuration > this.m_outroDuration {
      this.FillIntroAnimationStart();
    } else {
      this.FillOutroAnimationStart();
    };
    this.GetRootWidget().Reparent(inkWidgetRef.Get(this.m_grid) as inkCompoundWidget);
  }

  public final func Update(timeLeft: Float, stackCount: Uint32) -> Void {
    let fraction: Float;
    let updatedSize: Float;
    if timeLeft <= 0.01 {
      updatedSize = 0.00;
      this.GetRootWidget().SetVisible(false);
    } else {
      fraction = timeLeft / this.m_initialDuration;
      updatedSize = fraction;
    };
    inkWidgetRef.Get(this.m_sprite).SetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition", AbsF(updatedSize));
    this.SetTimeRemaining(timeLeft);
    this.SetStackCount(Cast(stackCount));
    if timeLeft <= this.m_outroDuration {
      this.FillOutroAnimationStart();
    };
  }

  private final func SetStackCount(count: Int32) -> Void {
    if count <= 1 {
      inkWidgetRef.SetVisible(this.m_stackCount, false);
    } else {
      inkWidgetRef.SetVisible(this.m_stackCount, true);
      inkTextRef.SetText(this.m_stackCount, IntToString(count));
    };
  }

  private final func SetTimeRemaining(time: Float) -> Void {
    let fraction: Int32;
    let gameTime: GameTime;
    let wholeNumber: Int32;
    let textParams: ref<inkTextParams> = new inkTextParams();
    this.ConvertFloatToTime(time, gameTime, wholeNumber, fraction);
    if GameTime.Minutes(gameTime) <= 0 {
      inkTextRef.SetText(this.m_timeRemaining, this.m_defaultTimeRemainingText);
      textParams.AddNumber("value", wholeNumber);
      textParams.AddNumber("millis", fraction);
      inkTextRef.SetTextParameters(this.m_timeRemaining, textParams);
    } else {
      inkTextRef.SetText(this.m_timeRemaining, "{TIME,time,mm:ss}");
      textParams.AddTime("TIME", gameTime);
      inkTextRef.SetTextParameters(this.m_timeRemaining, textParams);
    };
  }

  private final const func ConvertFloatToTime(f: Float, out time: GameTime, out totalSeconds: Int32, out fraction: Int32) -> Void {
    time = GameTime.MakeGameTime(0, 0, 0, Cast(f));
    totalSeconds = GameTime.Minutes(time) * 60;
    totalSeconds += GameTime.Seconds(time);
    fraction = Cast((f - Cast(FloorF(f))) * 100.00);
    return;
  }

  private final func FillIntroAnimationStart() -> Void {
    this.m_currentAnimProxy = this.PlayLibraryAnimation(n"FillIntroAnimation");
    this.m_currentAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFillIntroAnimationOver");
  }

  protected cb func OnFillIntroAnimationOver(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_state = ECooldownIndicatorState.Filling;
    inkWidgetRef.SetSize(this.m_fill, this.m_fullSizeValue);
    proxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFillIntroAnimationOver");
  }

  private final func FillOutroAnimationStart() -> Void {
    this.m_currentAnimProxy = this.PlayLibraryAnimation(n"FillOutroAnimation");
    this.m_state = ECooldownIndicatorState.Outro;
    this.m_currentAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFillOutroAnimationOver");
  }

  protected cb func OnFillOutroAnimationOver(proxy: ref<inkAnimProxy>) -> Bool {
    proxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFillOutroAnimationOver");
    this.HideCooldownWidget();
  }

  private final func HideCooldownWidget() -> Void {
    this.GetRootWidget().SetVisible(false);
    this.m_state = ECooldownIndicatorState.Pooled;
  }

  public final func GetState() -> ECooldownIndicatorState {
    return this.m_state;
  }

  public final func RemoveCooldown() -> Void {
    this.m_currentAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFillIntroAnimationOver");
    this.m_currentAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFillOutroAnimationOver");
    this.HideCooldownWidget();
  }

  public final func IsIDMatch(id: TweakDBID) -> Bool {
    return this.m_buffData.buffID == id;
  }
}
