package com.github.shokohara.leagueoflegends

import japgolly.scalajs.react.CtorType
import japgolly.scalajs.react._
import japgolly.scalajs.react.component.Scala.Component
import japgolly.scalajs.react.vdom.html_<^._

object TopPage {

  val component: Component[String, Unit, Unit, CtorType.Props] = ScalaComponent.builder[String]("TopPage").render_P(rend).build

  def rend(text: String) =
    <.div(
      ^.display.flex,
      text
    )
}
