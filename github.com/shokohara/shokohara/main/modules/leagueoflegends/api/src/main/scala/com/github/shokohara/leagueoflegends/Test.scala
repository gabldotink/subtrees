package com.github.shokohara.leagueoflegends

import com.merakianalytics.orianna.Orianna
import com.merakianalytics.orianna.types.common.Region
import munit.CatsEffectSuite
import zio.Runtime
import zio.ZEnv

class Test extends CatsEffectSuite {
  implicit val runtime: Runtime[ZEnv] = Runtime.default
  test("") {
    Orianna.setRiotAPIKey(Main.appConfig.riotApiKey)
    Orianna.setDefaultRegion(Region.JAPAN)
    Orianna.getChampions()
  }
}
