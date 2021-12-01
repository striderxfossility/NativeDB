
public class ToiletController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ToiletControllerPS extends ScriptableDeviceComponentPS {

  @default(ToiletControllerPS, 5.0f)
  protected edit let m_flushDuration: Float;

  @attrib(customEditor, "AudioEvent")
  protected let m_flushSFX: CName;

  protected let m_flushVFXname: CName;

  protected let m_isFlushing: Bool;

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.m_isFlushing {
      ArrayPush(actions, this.ActionFlush());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func GetFlushSFX() -> CName {
    return this.m_flushSFX;
  }

  public final func GetFlushVFX() -> CName {
    return this.m_flushVFXname;
  }

  protected final func ActionFlush() -> ref<Flush> {
    let action: ref<Flush> = new Flush();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.SetDurationValue(this.m_flushDuration);
    action.CreateInteraction();
    return action;
  }

  public final func OnFlush(evt: ref<Flush>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if evt.IsStarted() {
      this.m_isFlushing = true;
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.m_isFlushing = false;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }
}
