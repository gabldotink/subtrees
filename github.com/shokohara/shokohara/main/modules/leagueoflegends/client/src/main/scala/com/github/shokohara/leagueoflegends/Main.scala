package com.github.shokohara.leagueoflegends

import scala.scalajs.LinkingInfo
import scala.scalajs.js.annotation.JSExportTopLevel

import japgolly.scalajs.react.raw.ReactDOM
import org.scalajs.dom

object Main {

  @JSExportTopLevel("main")
  def main(): Unit = {

    if (LinkingInfo.developmentMode) {}

    val elementId = "root"
    val container = Option(dom.document.getElementById(elementId)).getOrElse {
      val elem = dom.document.createElement("div")
      elem.id = elementId
      dom.document.body.appendChild(elem)
      elem
    }
    ReactDOM.render(TopPage.component.apply(LinkingInfo.developmentMode.toString).rawNode, container)
  }
}
