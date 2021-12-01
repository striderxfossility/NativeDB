
public class CSH extends IScriptable {

  public final static func GetCooldownSystem(go: ref<GameObject>) -> ref<ICooldownSystem> {
    return GameInstance.GetCooldownSystem(go.GetGame());
  }
}
