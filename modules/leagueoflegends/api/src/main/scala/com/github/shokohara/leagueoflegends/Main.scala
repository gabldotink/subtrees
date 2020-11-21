package com.github.shokohara.leagueoflegends

import scala.concurrent.ExecutionContext

import _root_.pureconfig.ConfigSource
import _root_.pureconfig.generic.auto._
import cats.implicits._
import com.softwaremill.macwire.wire
import com.typesafe.scalalogging.StrictLogging
import eu.timepit.refined.auto._
import eu.timepit.refined.refineMV
import eu.timepit.refined.string.IPv4
import org.http4s.HttpRoutes
import org.http4s.server.Router
import org.http4s.server.blaze.BlazeServerBuilder
import org.http4s.server.middleware.CORS
import org.http4s.syntax.kleisli._
import zio.App
import zio.ExitCode
import zio.Runtime
import zio.Task
import zio.URIO
import zio.ZEnv
import zio.interop.catz._
import zio.interop.catz.implicits._

object Main extends StrictLogging with App {
  implicit val runtime: Runtime[ZEnv] = Runtime.default

  def serverBuilder(ec: ExecutionContext, routes: HttpRoutes[Task]): BlazeServerBuilder[Task] =
    BlazeServerBuilder[Task](ec)
      .withBanner("overwritten http4s banner" :: Nil)
      .bindHttp(host = refineMV[IPv4]("0.0.0.0"), port = 8081)
      .withHttpApp(CORS(Router("/" -> routes).orNotFound))

  def appConfig: AppConfig = ConfigSource.default.loadOrThrow[AppConfig]

  def run(args: List[String]): URIO[ZEnv, ExitCode] =
    //    ThisBuildInfo.toMap.map { case (a, b) => s"$a: ${b.toString.trim}" }.foreach(logger.info(_: String))
    serverBuilder(platform.executor.asEC, wire[MainService].route).serve.compile.drain
      .leftMap(throw _).as(ExitCode.success)

}
