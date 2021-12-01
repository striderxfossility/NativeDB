
public class sampleTimeListener extends TimeDilationListener {

  public let myOwner: wref<sampleTimeDilatable>;

  protected cb func OnFinished(reason: CName) -> Bool {
    this.myOwner.OnFinished(reason);
  }

  public final func SetOwner(owner: ref<sampleTimeDilatable>) -> Void {
    Log("owner set for minigame listener");
    this.myOwner = owner;
  }
}

public class sampleTimeDilatable extends TimeDilatable {

  public let listener: ref<sampleTimeListener>;

  protected cb func OnGameAttached() -> Bool {
    if !IsDefined(this.listener) {
      this.listener = new sampleTimeListener();
      this.listener.SetOwner(this);
    };
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    GameInstance.GetTimeSystem(this.GetGame()).SetTimeDilation(n"ScriptsDebug", 0.20, 2.00, n"Linear", n"Log", this.listener);
    Log("Check for existing");
    Log(ToString(GameInstance.GetTimeSystem(this.GetGame()).IsTimeDilationActive(n"ScriptsDebug")));
    Log("Check for not existing");
    Log(ToString(GameInstance.GetTimeSystem(this.GetGame()).IsTimeDilationActive(n"NotExistingReason")));
    Log("Check for any - no parameter passed");
    Log(ToString(GameInstance.GetTimeSystem(this.GetGame()).IsTimeDilationActive()));
  }

  protected cb func OnTimeDilationFinished() -> Bool {
    Log("finished TIME DILATION");
  }

  public final func OnFinished(reason: CName) -> Void {
    Log("TIME DILATION FINISHED");
    if Equals(reason, n"ScriptsDebug") {
      Log("reason was Scripts Debug");
    };
  }
}
