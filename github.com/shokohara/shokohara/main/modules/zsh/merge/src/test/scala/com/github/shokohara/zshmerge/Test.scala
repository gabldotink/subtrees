package com.github.shokohara.zshmerge

import java.nio.file.Paths

import cats.effect.{Blocker, IO}
import fs2.{io, text}
import munit.FunSuite

class Test extends FunSuite {
  val zshHistory = """: 1606183755:0;vim ./deploy.sh
                     |: 1606184373:0;curl -fLo ~/.vim/autoload/plug.vim --create-dirs \\
                     |    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\
                     |
                     |: 1606184409:0;vim ~/.vimrc
                     |""".stripMargin
  test("正常にパースする") {
    assertEquals(
      Main.function(zshHistory.linesIterator.zipWithIndex.map(x => (x._1, (x._2 + 1).toLong)).toList),
      List(
        (""": 1606183755:0;vim ./deploy.sh""", 1L),
        (
          """: 1606184373:0;curl -fLo ~/.vim/autoload/plug.vim --create-dirs \\
            |    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\
            |""".stripMargin,
          2L
        ),
        (
          """: 1606184409:0;vim ~/.vimrc""".stripMargin,
          5L
        )
      )
    )
  }

  test("fs2で正常にパースする") {
    import Main._
    import cats.implicits._
    import cats.effect.implicits._
    assertEquals(
      fs2.Stream
        .emit(zshHistory)
        .through(text.lines)
        .zipWithIndex
        .map { case (s, l) => (s, l + 1) }
        .through(function2[IO]).compile.toList
        .map(_.map((hoge _).tupled).sequence.fold(s => throw new RuntimeException(s), identity))
        .map(_.map { case ((i, s), l) => (s, l) })
        .unsafeRunSync(),
      List(
        ("""vim ./deploy.sh""", 1L),
        (
          """curl -fLo ~/.vim/autoload/plug.vim --create-dirs \\
          |    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\
          |""".stripMargin,
          2L
        ),
        (
          """vim ~/.vimrc
            |""".stripMargin,
          5L
        )
      )
    )
  }
}
