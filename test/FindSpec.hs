{-# Language OverloadedStrings #-}
{-# Language ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
module FindSpec (main, spec) where

import Test.Hspec.HUnit ()
import Test.HUnit
import Test.Hspec.Monadic

import Shelly
-- import qualified Data.Text.Lazy as LT
-- default (LT.Text)

main :: IO ()
main = hspecX spec

spec :: Specs
spec = do
  describe "relativeTo" $ do
    it "relative to non-existent dir" $ do
      res <- shelly $ relativeTo "rel/" "rel/foo"
      res @?= "foo"
      res <- shelly $ relativeTo "rel" "rel/foo"
      res @?= "rel/foo"

    it "relative to existing dir" $ do
      res <- shelly $ relativeTo "test/" "test/drain.hs"
      res @?= "drain.hs"
      res <- shelly $ relativeTo "test" "test/drain.hs"
      res @?= "drain.hs"

    it "abs path relative to existing dir" $ do
      res <- shelly $ relativeTo "test/" "/Users/gweber/proj/hs/Shelly.hs/test/drain.hs"
      res @?= "drain.hs"
      res <- shelly $ relativeTo "test" "/Users/gweber/proj/hs/Shelly.hs/test/drain.hs"
      res @?= "drain.hs"

  describe "find" $ do
    it "empty list for empty dir" $ do
      let d = "deleteme"
      res <- shelly $ do
        mkdir_p d
        res <- find d
        rm_rf d
        return res
      res @?= []

    it "lists files" $ do
      res <- shelly $ find "test" >>= mapM (relativeTo "test")
      res @?= ["drain.hs", "drain.sh", "FindSpec.hs", "main.hs", "Smoke.hs"]

  describe "findRelative" $ do
    it "relative dir listing" $ do
      res <- shelly $ findRelative "test"
      res @?= ["drain.hs", "drain.sh", "FindSpec.hs", "main.hs", "Smoke.hs"]