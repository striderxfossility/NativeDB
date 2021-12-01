
public class MinigameGenerationRule_Test extends MinigameGenerationRule {

  protected func OnProcessRule(size: Uint32, out grid: array<array<GridCell>>) -> Bool {
    let i: Int32 = 0;
    while i < Cast(size) {
      grid[i][i].rarityValue = 1;
      i += 1;
    };
    return true;
  }
}
