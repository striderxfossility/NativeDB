
public class BasicDistractionDevice extends InteractiveDevice {

  protected let m_animFeatureDataDistractor: ref<AnimFeature_DistractionState>;

  protected let m_animFeatureDataNameDistractor: CName;

  protected edit const let m_distractionComponentSwapNamesToON: array<CName>;

  protected edit const let m_distractionComponentSwapNamesToOFF: array<CName>;

  private let m_distractionComponentON: array<ref<IPlacedComponent>>;

  private let m_cdistractionComponentOFF: array<ref<IPlacedComponent>>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_distractionComponentSwapNamesToON) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_distractionComponentSwapNamesToON[i], n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_distractionComponentSwapNamesToOFF) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_distractionComponentSwapNamesToOFF[i], n"IPlacedComponent", true);
      i += 1;
    };
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_distractionComponentSwapNamesToON) {
      ArrayPush(this.m_distractionComponentON, EntityResolveComponentsInterface.GetComponent(ri, this.m_distractionComponentSwapNamesToON[i]) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_distractionComponentSwapNamesToOFF) {
      ArrayPush(this.m_cdistractionComponentOFF, EntityResolveComponentsInterface.GetComponent(ri, this.m_distractionComponentSwapNamesToOFF[i]) as IPlacedComponent);
      i += 1;
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BasicDistractionDeviceController;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_animFeatureDataDistractor = new AnimFeature_DistractionState();
    this.m_animFeatureDataNameDistractor = n"distraction";
    super.OnGameAttached();
    if (this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetForceAnimationSystem() {
      this.ToggleForcedVisibilityInAnimSystem(n"DistractionDeviceSpecialForce", true, 0.00);
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    if (this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetForceAnimationSystem() {
      this.ToggleForcedVisibilityInAnimSystem(n"DistractionDeviceSpecialForce", false, 0.00);
    };
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.PlayTransformAnimation(n"turnON", true);
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.StopTransformDistractAnimation(n"turnON");
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected cb func OnSpiderbotDistractDevicePerformed(evt: ref<SpiderbotDistractDevicePerformed>) -> Bool {
    if evt.IsStarted() {
      this.StartDistraction(true);
    } else {
      this.StopDistraction();
    };
  }

  protected cb func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> Bool {
    super.OnQuickHackDistraction(evt);
    if evt.IsStarted() {
      this.StartDistraction(true);
    } else {
      this.StopDistraction();
    };
  }

  protected cb func OnQuestStartGlitch(evt: ref<QuestStartGlitch>) -> Bool {
    super.OnQuestStartGlitch(evt);
    this.StartDistraction(true);
  }

  protected cb func OnQuestStopGlitch(evt: ref<QuestStopGlitch>) -> Bool {
    super.OnQuestStopGlitch(evt);
    this.StopDistraction();
  }

  protected func StartDistraction(opt loopAnimation: Bool) -> Void {
    this.PlayDistractAnimation(loopAnimation);
    this.EffectsOnStartPlay();
    this.MeshSwapOnDistraction(true);
  }

  protected func StopDistraction() -> Void {
    this.StopDistractAnimation();
    this.EffectsOnStartStop();
    this.MeshSwapOnDistraction(false);
  }

  protected func PlayDistractAnimation(opt loop: Bool) -> Void {
    if Equals((this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetAnimationType(), EAnimationType.REGULAR) {
      this.PlayAnimgraphTransformAnimation();
    } else {
      if Equals((this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetAnimationType(), EAnimationType.TRANSFORM) {
        this.PlayTransformAnimation(n"distraction", loop);
      };
    };
  }

  protected func StopDistractAnimation() -> Void {
    if Equals((this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetAnimationType(), EAnimationType.REGULAR) {
      this.StopAnimgraphTransformAnimation();
    } else {
      if Equals((this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetAnimationType(), EAnimationType.TRANSFORM) {
        this.StopTransformDistractAnimation(n"distraction");
      };
    };
  }

  protected func PlayAnimgraphTransformAnimation() -> Void {
    this.m_animFeatureDataDistractor.isOn = true;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataNameDistractor, this.m_animFeatureDataDistractor);
  }

  protected func StopAnimgraphTransformAnimation() -> Void {
    this.m_animFeatureDataDistractor.isOn = false;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataNameDistractor, this.m_animFeatureDataDistractor);
  }

  protected func PlayTransformAnimation(animationName: CName, opt loop: Bool) -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.animationName = animationName;
    playEvent.timeScale = 1.00;
    playEvent.looping = loop;
    if loop {
      playEvent.timesPlayed = 1u;
    } else {
      playEvent.timesPlayed = 100u;
    };
    this.QueueEvent(playEvent);
  }

  protected func StopTransformDistractAnimation(animationName: CName) -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.timeScale = 1.00;
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.animationName = animationName;
    this.QueueEvent(playEvent);
  }

  protected final func EffectsOnStartPlay() -> Void {
    let effectNames: array<CName> = (this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetEffectOnStartNames();
    let i: Int32 = 0;
    while i < ArraySize(effectNames) {
      GameObjectEffectHelper.StartEffectEvent(this, effectNames[i]);
      i += 1;
    };
  }

  protected final func EffectsOnStartStop(opt shouldStop: Bool) -> Void {
    let effectNames: array<CName> = (this.GetDevicePS() as BasicDistractionDeviceControllerPS).GetEffectOnStartNames();
    let i: Int32 = 0;
    while i < ArraySize(effectNames) {
      if shouldStop {
        GameObjectEffectHelper.StopEffectEvent(this, effectNames[i]);
      } else {
        GameObjectEffectHelper.BreakEffectLoopEvent(this, effectNames[i]);
      };
      i += 1;
    };
  }

  protected final func MeshSwapOnDistraction(start: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_distractionComponentON) {
      this.m_distractionComponentON[i].Toggle(start);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_cdistractionComponentOFF) {
      this.m_cdistractionComponentOFF[i].Toggle(!start);
      i += 1;
    };
  }
}
