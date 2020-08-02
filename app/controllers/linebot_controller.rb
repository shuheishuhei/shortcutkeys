class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          seed1 = select_word
          seed2 = select_word
          while seed1 == seed2
            seed2 = select_word
          end
          message = [{
            type: 'text',
            text: "ショートカットキーを覚えましょい"
          },{
            type: 'text',
            text: "#{seed1}\n#{seed2}"
          }]
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def select_word
    seeds = ["⌘ + Q アプリケーションを終了","⌘ + W ウィンドウを閉じる","⌘ + option + W 全ウィンドウを閉じる","⌘ + M ウィンドウをDockにしまう","⌘ + H アクティブウィンドウを隠す","⌘ + C コピーする","⌘ + X 切り取る", "⌘ + V 貼り付ける","⌘ + A 全てを選択する","⌘ + R 表示内容を更新する", "⌘ + S 保存する","⌘ + shift + S 別名で保存する","⌘ + P 印刷する","⌘ + delete ファイルをゴミ箱に移動","⌘ + N 新規Finderウィンドウを開く","⌘ + D ファイルを複製する","⌘ + L エイリアス(ショートカットフォルダ)を作成する","⌘ + F 検索する","⌘ + I ファイルの情報を見る","return ファイルのリネーム","⌘ + shift + N 新規フォルダを作成する","control + D カーソルの右側の文字を削除する","control + K カーソルの右側の文字を全て削除する","control + A カーソルを行頭に移動する","⌘ + shift + 3 スクリーンショット(全画面)を撮影する","⌘ + shift + 4 スクリーンショット(選択範囲)を撮影する","⌘ + shift + delete ゴミ箱を空にする(確認あり)","⌘ + shift + option + delete ゴミ箱を確認なしで空にする","⌘ + tab アプリケーションの切り替え","⌘ + shift + H ホームフォルダを開く","control + space Spotlightを開く","⌘ + shift + U ユーティリティフォルダを開く","control + F2 メニューに移動する","⌘ + shift + A アプリケーションフォルダを開く","⌘ + O or ⌘ + ↓ 関連したアプリケーションで開く","⌘ + , アプリケーションの環境設定を開く","⌘ + ↑ Finderで上の階層に移動する","⌘ + option + control + 8 画面の色を反転"]
    seeds.sample
  end
end
