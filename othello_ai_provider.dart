// ai
// 解析の流れ
// 現在の盤面情報を渡す
// 置ける場所(true)に対して、読んでいく
// 読み切ったら最もいい評価を返す
// 返された評価値を表示する
// 途中の段階を全て保存しておく(Listで管理、進めるたびに表示される)
// 白番への変換は*-1で表す
//
// 読み切りに必要なもの
// 指定した場所に対して、プラス
//

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OthelloAiInfo {
  const OthelloAiInfo({
    required this.stoneColor,
    required this.available,
  });

  final Color stoneColor;
  final bool available;
}

class OthelloAiNotifier extends StateNotifier<List<List<OthelloAiInfo>>> {
  OthelloAiNotifier() : super([]);

  void resetState() {
    state = [
      for (int i = 0; i < 8; i++)
        [
          for (int ii = 0; ii < 8; ii++)
            if (i == 3 && ii == 4 || i == 4 && ii == 3)
              const OthelloAiInfo(stoneColor: Colors.black, available: false)
            else if (i == 3 && ii == 3 || i == 4 && ii == 4)
              const OthelloAiInfo(stoneColor: Colors.white, available: false)
            else if (i == 2 && ii == 3 || i == 3 && ii == 2 || i == 4 && ii == 5 || i == 5 && ii == 4)
              const OthelloAiInfo(stoneColor: Colors.lightGreen, available: true)
            else
              const OthelloAiInfo(stoneColor: Colors.lightGreen, available: false)
        ],
    ];
  }

  // 以下のListを用いて8方向の石の状況を確認する
  List directions = [
    [0, 1], // 右
    [1, 0], // 下
    [0, -1], // 左
    [-1, 0], // 上
    [1, 1], // 右下
    [-1, -1], // 左上
    [1, -1], // 左下
    [-1, 1], // 右上
  ];

  // 処理に用いる変数
  String currentPlayer = 'black';
  int directionColumn = 0;
  int directionRow = 0;
  int flipTimes = 0;

  // 変数の初期化を行う関数
  void resetValiable() {
    directionColumn = 0;
    directionRow = 0;
    flipTimes = 0;
  }

  void changeStones(int column, int row) {
    // 置ける場所がない場合、終了を知らせる
    if (currentPlayer == 'end') {
      debugPrint('おわり');
    }
    // 現在の手番で着手できるマスが選択された場合、石をひっくり返す処理を実行
    if (state[column][row].stoneColor == Colors.lightGreen && state[column][row].available) {
      if (currentPlayer == 'black') {
        for (List<int> direction in directions) {
          directionColumn = directionColumn + direction[0];
          directionRow = directionRow + direction[1];
          while (column + directionColumn >= 0 && column + directionColumn <= 7 && row + directionRow >= 0 && row + directionRow <= 7 && state[column + directionColumn][row + directionRow].stoneColor != Colors.lightGreen) {
            flipTimes++;
            if (flipTimes == 1 && state[column + directionColumn][row + directionRow].stoneColor == Colors.black) {
              flipTimes = 0;
              break;
            }

            if (flipTimes >= 2 && state[column + directionColumn][row + directionRow].stoneColor == Colors.black) {
              for (int i = 0; i < flipTimes; i++) {
                changeStateColors(column + i * direction[0], row + i * direction[1]);
              }
              flipTimes = 0;
              changeStateColors(column, row);
              break;
            }
            directionColumn = directionColumn + direction[0];
            directionRow = directionRow + direction[1];
          }
          resetValiable();
        }
      } else if (currentPlayer == 'white') {
        for (List<int> direction in directions) {
          directionColumn = directionColumn + direction[0];
          directionRow = directionRow + direction[1];
          while (column + directionColumn >= 0 && column + directionColumn <= 7 && row + directionRow >= 0 && row + directionRow <= 7 && state[column + directionColumn][row + directionRow].stoneColor != Colors.lightGreen) {
            flipTimes++;
            if (flipTimes == 1 && state[column + directionColumn][row + directionRow].stoneColor == Colors.white) {
              flipTimes = 0;
              break;
            }
            if (flipTimes >= 2 && state[column + directionColumn][row + directionRow].stoneColor == Colors.white) {
              for (int i = 0; i < flipTimes; i++) {
                changeStateColors(column + i * direction[0], row + i * direction[1]);
              }
              changeStateColors(column, row);
              flipTimes = 0;
              break;
            }
            directionColumn = directionColumn + direction[0];
            directionRow = directionRow + direction[1];
          }
          resetValiable();
        }
      }
      currentPlayer = whichTurn(currentPlayer);
    }
    state = [...state];
  }

  // 次の手番で石が置けるかを判別する関数
  // 次の相手の色が置けない場合はpassになり同じ色を返す
  // 双方が置けない場合はendを返す
  String whichTurn(turn) {
    int manageTurn = 1;
    Map turns = {1: 'black', -1: 'white'};
    int availableCount = 0;
    int passCount = 0;
    while (passCount <= 2) {
      if (turn == 'black') {
        for (int column = 0; column < 8; column++) {
          for (int row = 0; row < 8; row++) {
            if (state[column][row].stoneColor == Colors.lightGreen) {
              for (List<int> direction in directions) {
                directionColumn = directionColumn + direction[0];
                directionRow = directionRow + direction[1];
                while (column + directionColumn >= 0 && column + directionColumn <= 7 && row + directionRow >= 0 && row + directionRow <= 7 && state[column + directionColumn][row + directionRow].stoneColor != Colors.lightGreen) {
                  flipTimes++;
                  if (flipTimes == 1 && state[column + directionColumn][row + directionRow].stoneColor == Colors.white) {
                    resetValiable();
                    break;
                  }
                  if (flipTimes >= 2 && state[column + directionColumn][row + directionRow].stoneColor == Colors.white) {
                    changeStateAvailable(column, row);
                    resetValiable();
                    availableCount++;
                    break;
                  }
                  directionColumn = directionColumn + direction[0];
                  directionRow = directionRow + direction[1];
                }
                resetValiable();
              }
            }
          }
        }
        if (availableCount > 0) {
          return 'white';
        }
        availableCount = 0;
      } else {
        for (int column = 0; column < 8; column++) {
          for (int row = 0; row < 8; row++) {
            for (List<int> direction in directions) {
              if (state[column][row].stoneColor == Colors.lightGreen) {
                directionColumn = directionColumn + direction[0];
                directionRow = directionRow + direction[1];
                while (column + directionColumn >= 0 && column + directionColumn <= 7 && row + directionRow >= 0 && row + directionRow <= 7 && state[column + directionColumn][row + directionRow].stoneColor != Colors.lightGreen) {
                  flipTimes++;
                  if (flipTimes == 1 && state[column + directionColumn][row + directionRow].stoneColor == Colors.black) {
                    resetValiable();
                    break;
                  }
                  if (flipTimes >= 2 && state[column + directionColumn][row + directionRow].stoneColor == Colors.black) {
                    changeStateAvailable(column, row);
                    resetValiable();
                    availableCount++;
                    break;
                  }
                  directionColumn = directionColumn + direction[0];
                  directionRow = directionRow + direction[1];
                }
                resetValiable();
              }
            }
          }
        }
        if (availableCount > 0) {
          return 'black';
        }
        availableCount = 0;
      }
      manageTurn = manageTurn * -1;
      turn = turns[manageTurn];
      passCount++;
    }
    return 'end';
  }

  // stateの中身を書き換える関数
  void changeStateColors(column, row) {
    if (currentPlayer == 'black') {
      state = [
        for (int i = 0; i < 8; i++)
          [
            for (int j = 0; j < 8; j++)
              if (i == column && j == row) const OthelloAiInfo(stoneColor: Colors.black, available: false) else OthelloAiInfo(stoneColor: state[i][j].stoneColor, available: false)
          ],
      ];
    } else {
      state = [
        for (int i = 0; i < 8; i++)
          [
            for (int j = 0; j < 8; j++)
              if (i == column && j == row) const OthelloAiInfo(stoneColor: Colors.white, available: false) else OthelloAiInfo(stoneColor: state[i][j].stoneColor, available: false)
          ],
      ];
    }
  }

  void changeStateAvailable(int column, int row) {
    state = [
      for (int i = 0; i < 8; i++)
        [
          for (int j = 0; j < 8; j++)
            if (i == column && j == row) const OthelloAiInfo(stoneColor: Colors.lightGreen, available: true) else state[i][j]
        ],
    ];
  }

  // 正式な解析プログラム
  List<List<List<int>>> analyze(board, String currentPlayerInAnalyze) {
    state = [
      for (int i = 0; i < 8; i++) [for (int j = 0; j < 8; j++) OthelloAiInfo(stoneColor: board[i][j].stoneColor, available: board[i][j].available)],
    ];

    int blancCount = 0;
    List<List<List<int>>> results = [];
    List<List<List<int>>> temporaryResults = [];
    List anotherState = [...state]; // analyzeを始めた時の初期値を保存する変数
    int count = 0;

    for (int column = 0; column < 8; column++) {
      for (int row = 0; row < 8; row++) {
        if (state[column][row].available) {
          results.add([[]]);
          results[count][0].addAll([column, row]);
          count++;
        }
        if (state[column][row].stoneColor == Colors.lightGreen) {
          blancCount++;
        }
      }
    }
    count = 0;

    int changeStonesCount = 1;
    while (changeStonesCount < blancCount) {
      // 空きマス数が多いと処理不可能な計算量が発生するため10マス以下に制限
      if (changeStonesCount > 10) {
        break;
      }
      for (List<List<int>> result in results) {
        currentPlayer = currentPlayerInAnalyze;
        for (int i = 0; i < changeStonesCount; i++) {
          changeStones(result[i][0], result[i][1]);
        }
        for (int column = 0; column < 8; column++) {
          for (int row = 0; row < 8; row++) {
            if (state[column][row].available) {
              temporaryResults.add([
                for (int i = 0; i < changeStonesCount; i++) [result[i][0], result[i][1]],
                [column, row]
              ]);
            }
          }
        }
        state = [...anotherState];
      }
      changeStonesCount++;
      results = [];
      results.addAll(temporaryResults);
      temporaryResults = [];
    }
    // 結果記入
    int countBlack = 0;
    int countWhite = 0;
    for (List<List<int>> result in results) {
      currentPlayer = currentPlayerInAnalyze;
      for (int i = 0; i < changeStonesCount; i++) {
        changeStones(result[i][0], result[i][1]);
      }
      for (int column = 0; column < 8; column++) {
        for (int row = 0; row < 8; row++) {
          if (state[column][row].stoneColor == Colors.black) {
            countBlack++;
          }
          if (state[column][row].stoneColor == Colors.white) {
            countWhite++;
          }
        }
      }
      result.addAll([
        [countBlack],
        [countWhite]
      ]);
      countBlack = countWhite = 0;

      state = [...anotherState];
    }
    return results;
    // for (List<List<int>> result in results) {
    //   debugPrint('${result[0]} ${result[1]} ${result[2]} ${result[3]} ${result[4]} ${result[5]} ${result[6]}');
    //   debugPrint('黒: ${result[7][0]}石');
    //   debugPrint('白: ${result[8][0]}石');
    // }
  }

  void current() {
    debugPrint(currentPlayer);
  }
}

class OthelloRatingNotifier extends StateNotifier<List<List<List<List<int>>>>> {
  OthelloRatingNotifier()
      : super(
          [
            for (int i = 0; i < 8; i++)
              [
                for (int j = 0; j < 8; j++)
                  [
                    [1],
                    [],
                    [],
                  ]
              ],
          ],
        );

  void resetState() {
    debugPrint('in reset');
    state = [
      for (int i = 0; i < 8; i++)
        [
          for (int j = 0; j < 8; j++)
            [
              [100],
              [],
              [],
            ]
        ],
    ];
    debugPrint('in reset');
    for (var k in state) {
      debugPrint(k.toString());
    }
  }

  void setRating(List<List<List<int>>> board) {
    Function isEqual = const ListEquality().equals;
    List<List<List<int>>> firstFlips = [
      [[]]
    ]; // forループの1回目でrange_errorを出さないために、配列の中に空の配列をあらかじめ定義している
    for (List<List<int>> result in board) {
      if (isEqual(firstFlips.last[0], result[0])) {
      } else {
        firstFlips.addAll([
          [result[0], [], []]
        ]);
      }
    }
    firstFlips.removeAt(0);
    debugPrint(firstFlips.toString());

    List anotherState = [...state]; // analyzeを始めた時の初期値を保存する変数

    // for (List<List<int>> result in board) {
    //   debugPrint(result.toString());
    // }

    for (var result in board) {
      for (var firstFlip in firstFlips) {
        if (isEqual(result[0], firstFlip[0])) {
          firstFlip[1].addAll(result[result.length - 2]);
          firstFlip[2].addAll(result[result.length - 1]);
        }
      }
    }
    for (var firstFlip in firstFlips) {
      firstFlip[1] = firstFlip[1].toSet().toList();
      firstFlip[2] = firstFlip[2].toSet().toList();
    }

    // debugPrint(firstFlips.toString());
    // [[ [黒石list], [白石list]], ]
    List eee = [[], [], [], [], [], [], [], []];
    int count = 0;
    int iCount = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (firstFlips[count][0][0] == i && firstFlips[count][0][0] == j) {
          eee[iCount].addAll([
            [firstFlips[count][1]],
            [firstFlips[count][2]]
          ]);
          count++;
          if (count == firstFlips.length) {
            count--;
          }
        } else {
          eee[iCount].add(state[i][j]);
        }
        if (iCount < 7) {
          iCount++;
        }
      }
    }

    for (int i = 0; i < 8; i++) {
      debugPrint('${eee[0]} ${eee[1]} ${eee[2]} ${eee[3]} ${eee[4]} ${eee[5]} ${eee[6]} ${eee[7]}');
    }

    state = [...state];
  }
}

final othelloAiProvider = StateNotifierProvider.autoDispose<OthelloAiNotifier, List<List<OthelloAiInfo>>>((ref) => OthelloAiNotifier());
final othelloRatingProvider = StateNotifierProvider.autoDispose<OthelloRatingNotifier, List<List<List<List<int>>>>>((ref) => OthelloRatingNotifier());
