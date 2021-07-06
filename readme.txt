1. 作業用フォルダ作成
　作業用フォルダとして myapp というフォルダを作成してください

2. myappフォルダ内に以下のファイルをコピーしてください
　Dockerfile
　docker-compose.yml
　entrypoint.sh
　Gemfile
　Gemfile.lock（空ファイルを作成）


3. myappフォルダに移動
　コマンドラインでmyappフォルダに移動してください
　cd myapp

4. Railsプロジェクト作成
　以下のコマンドを実行してください
  docker-compose run web rails new . --force --no-deps --database=postgresql --skip-bundle

5. ビルド実行
　以下のコマンドを実行してください
　docker-compose build

6. Webpackerをインストールします
　以下のコマンドを実行してください
　docker-compose run web bundle exec rails webpacker:install

7. DB設定ファイル置き換え
　以下のファイルを置き換えてください
　config/database.yml
　
8. Dockerコンテナ起動
　以下のコマンドを実行してください
　docker-compose up -d

9. DB作成
　以下のコマンドを実行してください
　docker-compose run web rake db:create

10. ブラウザで以下のURLにアクセスしてください
　http://localhost:3000/

