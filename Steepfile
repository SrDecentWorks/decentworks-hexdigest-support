# D = Steep::Diagnostic
#
# target :lib do
#   signature "sig"
#   ignore_signature "sig/test"
#
#   check "lib"                       # Directory name
#   check "path/to/source.rb"         # File name
#   check "app/models/**/*.rb"        # Glob
#   # ignore "lib/templates/*.rb"
#
#   # library "pathname"              # Standard libraries
#   # library "strong_json"           # Gems
#
#   # configure_code_diagnostics(D::Ruby.default)      # `default` diagnostics setting (applies by default)
#   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
#   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
#   # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
#   # configure_code_diagnostics do |hash|             # You can setup everything yourself
#   #   hash[D::Ruby::NoMethod] = :information
#   # end
# end

# target :test do
#   unreferenced!                     # Skip type checking the `lib` code when types in `test` target is changed
#   signature "sig/test"              # Put RBS files for tests under `sig/test`
#   check "test"                      # Type check Ruby scripts under `test`
#
#   configure_code_diagnostics(D::Ruby.lenient)      # Weak type checking for test code
#
#   # library "pathname"              # Standard libraries
# end

target :lib do
  # 型検査をしたいrubyファイルが格納されているディレクトリ名
  check "lib"

  # 型定義を記述するRBSファイルが格納されているディレクトリ名
  #
  # sig          … gemに同梱する型定義
  # sig-external … 型検査のためだけに必要な型定義（gemには同梱しない）
  #                Railsジェネレータ用に ::Rails::Generators::Base の最小限のスタブを置いている。
  #                詳細は sig-external/rails/generators/base.rbs のコメントを参照。
  signature "sig", "sig-external"

  # 取り込みたいライブラリ
  # ::Date / ::Time / ::DateTime の拡張メソッド、および BigDecimal 対応の型定義。
  # activesupport / bigdecimal は rbs_collection.lock.yaml 経由で gem_rbs_collection から取得する。
  library "date"
  library "activesupport"
  library "bigdecimal"
end
