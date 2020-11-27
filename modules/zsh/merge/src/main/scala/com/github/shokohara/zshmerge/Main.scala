package com.github.shokohara.zshmerge

import java.nio.file.Paths
import java.time.Instant

import better.files.File
import cats.effect.{Blocker, Concurrent, ContextShift, IO, Resource}
import cats.implicits._
import eu.timepit.refined.api.Refined
import eu.timepit.refined.boolean.{And, Not}
import eu.timepit.refined.collection.Contains
import eu.timepit.refined.refineV
import eu.timepit.refined.W
import eu.timepit.refined.api.RefType.applyRef
import eu.timepit.refined.string.StartsWith
import fs2._

import scala.annotation.tailrec
import scala.concurrent.ExecutionContext
import scala.util.Try

object Main {

  type ZshHistoryRow = String

  def hoge(zshHistoryRow: ZshHistoryRow, lineNumber: Long): Either[RuntimeException, ((Instant, Long, String), Long)] = {
    val string = zshHistoryRow.drop(2).takeWhile(_.isDigit)
    for {
      long <- string.toLongOption.toRight(new RuntimeException(string))
      instant <- Try(Instant.ofEpochSecond(long)).toEither.leftMap(s => new RuntimeException(long.toString, s))
      second <-
        zshHistoryRow
          .dropWhile(_ != ':')
          .drop(1)
          .dropWhile(_ != ':')
          .drop(1)
          .takeWhile(_ != ';').toLongOption.toRight(new RuntimeException(zshHistoryRow))

    } yield ((instant, second, zshHistoryRow.drop(2).dropWhile(_ != ';').drop(1)), lineNumber)
  }

  val take = 2

  def main3[F[_]: Concurrent: ContextShift](p: String) =
    fs2.Stream
      .resource(Blocker[F]).flatMap(blocker =>
        io.file
          .readAll[F](Paths.get(p), blocker, 4096)
          .through(text.utf8Decode)
          .through(text.lines)
          .zipWithIndex
          .map { case (s, l) => (s, l + 1) }
      )
  type ZshHistoryRowPrefix = String Refined StartsWith[W.`": "`.T]
  type NotZshHistoryRowPrefix = String Refined Not[StartsWith[W.`": "`.T]]

  def temp2result(temp: (ZshHistoryRowPrefix, List[String], Long)): (String, Long) = {
    val (pre, list, lineNumber) = temp
    ((pre.value +: list).mkString(System.lineSeparator()), lineNumber)
  }

  def function(lineWithIndex: List[(String, Long)]): List[(String, Long)] = {
    @tailrec def f(lines: List[(String, Long)], temp: Option[(ZshHistoryRowPrefix, List[String], Long)], result: List[Option[(String, Long)]]): List[(String, Long)] = lines match {
      case head :: tail =>
        refineV[StartsWith[W.`": "`.T]](head._1) match {
          case Left(_)  => f(tail, Option[(ZshHistoryRowPrefix, List[String], Long)](temp.fold(???) { case (pre, list, lineNumber) => (pre, list :+ head._1, lineNumber) }), result)
          case Right(r) => f(tail, Option((r, Nil, head._2)), result :+ temp.map(temp2result))
        }
      case Nil => (result :+ temp.map(temp2result).toList).flatMap(_.toList)
    }
    f(lineWithIndex, None, Nil)
  }

  def main2[F[_]: Concurrent: ContextShift]: fs2.Stream[F, Either[RuntimeException, ((Instant, Long, String), Long)]] =
    fs2.Stream.resource(Blocker[F]).flatMap { blocker =>
      fs2.io
        .stdinUtf8(4096, blocker).through(text.lines).zipWithIndex
        .map { case (s, l) => (s, l + 1) }
        .dropLastIf(_.isEmpty)
        .take(take).map((hoge _).tupled)
    }

  def function2[F[_]]: Pipe[F, (String, Long), (String, Long)] = {
    def go(s: Stream[F, (String, Long)], temp: Option[(ZshHistoryRowPrefix, List[String], Long)]): Pull[F, (String, Long), Unit] =
      s.pull.uncons1.flatMap {
        case Some((head, tl)) =>
          refineV[StartsWith[W.`": "`.T]](head._1) match {
            case Left(_) => go(tl, Option[(ZshHistoryRowPrefix, List[String], Long)](temp.fold(???) { case (pre, list, lineNumber) => (pre, list :+ head._1, lineNumber) }))
            case Right(r) =>
              (temp.map(temp2result) match {
                case None    => Pull.output(Chunk.empty)
                case Some(x) => Pull.output(Chunk(x))
              }) >> go(tl, Option((r, Nil, head._2)))
          }
        case None =>
          (temp.map(temp2result) match {
            case None    => Pull.output(Chunk.empty)
            case Some(x) => Pull.output(Chunk(x))
          }) >> Pull.done
      }
    in => go(in, None).stream
  }
}
import com.monovore.decline._

object A
  extends CommandApp(
    name = "hello-world",
    header = "Says hello!",
    main = {
      import Main._
      implicit val cs = IO.contextShift(ExecutionContext.global)
      implicit val timer = IO.timer(ExecutionContext.global)
      val file1 = Opts.option[String]("target1", help = "Person to greet.")
      val output = Opts.option[String]("output", help = "Person to greet.")
      (file1, output).mapN { (file1, output) =>
//        main3[IO](user1).compile.toList
//          .map { x => x.foreach(println); x }
//          .map(function)
//          .map(_.map((hoge _).tupled).sequence.fold(s => throw new RuntimeException(s), identity).map(println))
//          .unsafeRunSync()

        File(output).write(
          main3[IO](file1)
            .through(function2[IO]).compile.toList
            .unsafeRunSync()
            .map((hoge _).tupled).sequence.fold(s => throw s, identity)
            .distinctBy(_._1._3)
            .sortBy(_._1._1.toEpochMilli)
            .map { case ((instant, second, string), _) => s": ${instant.getEpochSecond}:$second;$string" }
            .mkString(System.lineSeparator())
        )
      }
    }
  )
