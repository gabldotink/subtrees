package com.github.shokohara.leagueoflegends

import java.util.UUID

import scala.jdk.CollectionConverters._

import cats.implicits._
import com.merakianalytics.orianna.Orianna
import com.merakianalytics.orianna.types.common.Region
import com.merakianalytics.orianna.types.core.summoner.Summoner
import com.typesafe.scalalogging.StrictLogging
import eu.timepit.refined.api.Refined
import eu.timepit.refined.collection.NonEmpty
import eu.timepit.refined.refineV
import io.chrisdavenport.fuuid.FUUID
import org.http4s.HttpRoutes
import sttp.tapir.Codec
import sttp.tapir.CodecFormat
import sttp.tapir.DecodeResult.Error
import sttp.tapir.DecodeResult.Value
import sttp.tapir.server.http4s.ztapir._
import sttp.tapir.ztapir._
import sttp.tapir.ztapir.emptyOutput
import sttp.tapir.ztapir.endpoint
import sttp.tapir.ztapir.header
import zio.Task
import zio.UIO
import zio.ZIO
import zio.interop.catz._

class MainService(val appConfig: AppConfig) extends StrictLogging {

  val fuuidEmpty: FUUID = FUUID.fromUUID(new UUID(0, 0))

  val fuuidTask: ZIO[Any, FUUID, FUUID] = FUUID.randomFUUID[Task].mapError { throwable =>
    logger.error(fuuidEmpty.toString, throwable)
    fuuidEmpty
  }

  implicit val fuuidCodec: Codec[String, FUUID, CodecFormat.TextPlain] =
    Codec.string.mapDecode(s => FUUID.fromString(s).fold(Error(s, _), Value(_)))(_.toString())

  Orianna.setRiotAPIKey(appConfig.riotApiKey)
  Orianna.setDefaultRegion(Region.JAPAN)

  case class AppConfig(riotApiKey: String)
  val xRequestID = "X-Request-ID"
  val queryName = "input"
  type SummonerName = String Refined NonEmpty
  def textAreaForm(query: String) = s"""<form><textarea name="$queryName" rows="10" cols="35">$query</textarea><br /><input type="submit"/></form>"""
  def b(query: String): Either[String, List[SummonerName]] = query.lines.map(_.replace("がロビーに参加しました", "")).iterator().asScala.toList.traverse(refineV[NonEmpty](_: String))
  def c(sns: List[SummonerName]): List[Summoner] = Orianna.summonersNamed(sns.map(_.value).asJava).get().asScala.toList
  def d(sms: List[Summoner]): Either[String, List[Summoner]] = sms.map(_.getName).traverse(refineV[NonEmpty](_: String)).map(c)
  type T = List[(String, List[(String, List[String])])]

  def e(sms: List[Summoner]): T =
    sms.map(sm =>
      (
        sm.getName,
        sm.matchHistory().get().asScala.take(11).toList.drop(1).map(x =>
            (
              x.getParticipants.asScala.map(_.getSummoner.getName).toList.mkString(", "),
              x.getParticipants.asScala.map(_.getSummoner.getName).toList.filter(sms.map(_.getName()).filterNot(_ == sm.getName).contains(_))
            )
          )
      )
    )

  def show(xs: T): List[String] = xs.map { case (sn, list) =>
    s"""$sn
       |${list.mkString(System.lineSeparator())}""".stripMargin
  }

  def f(q: Option[String]): String =
    q.fold(textAreaForm(""))(x =>
      textAreaForm(x) + (System.lineSeparator() + b(x)
        .map(_.distinct)
        .map(c).flatMap(d).map(e).map(show).leftMap(_ :: Nil).merge.mkString(System.lineSeparator()))
        .replaceAll(System.lineSeparator(), "<br />")
    )

  val ep = endpoint.get
    .in("multiplysearch")
    .in(query[Option[String]](queryName))
    .out(header[FUUID](xRequestID))
    .out(htmlBodyUtf8)
    .errorOut(header[FUUID](xRequestID))
    .errorOut(emptyOutput)

  val route: HttpRoutes[Task] = ep
    .toRoutes(q =>
      for {
        _ <- UIO(println(q))
        fuuid <- FUUID.randomFUUID[Task].mapError { throwable =>
          logger.error(fuuidEmpty.toString, throwable)
          fuuidEmpty
        }
      } yield (fuuid, f(q))
    )
}
