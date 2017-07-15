;;; edn-el-test-suite.el --- Tests from edn.el

;; Author: Lars Andersen <expez@expez.com>, Arne Brasseur <arne@arnebrasseur.net>

;; Copyright (C) 2015  Lars Andersen

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(require 'ert)
(require 'edn)

(ert-deftest whitespace ()
  (should (null (clj-parse-edn-str "")))
  (should (null (clj-parse-edn-str " ")))
  (should (null (clj-parse-edn-str "   ")))
  (should (null (clj-parse-edn-str "	")))
  (should (null (clj-parse-edn-str "		")))
  (should (null (clj-parse-edn-str ",")))
  (should (null (clj-parse-edn-str ",,,,")))
  (should (null (clj-parse-edn-str "	  , ,
")))
  (should (null (clj-parse-edn-str"
  ,, 	")))
  (should (equal [a b c d] (clj-parse-edn-str "[a ,,,,,, b,,,,,c ,d]"))))

(ert-deftest symbols ()
  :tags '(edn symbol)
  (should (equal 'foo (clj-parse-edn-str "foo")))
  (should (equal 'foo\. (clj-parse-edn-str "foo.")))
  (should (equal '%foo\. (clj-parse-edn-str "%foo.")))
  (should (equal 'foo/bar (clj-parse-edn-str "foo/bar")))
  (equal 'some\#sort\#of\#symbol (clj-parse-edn-str "some#sort#of#symbol"))
  (equal 'truefalse (clj-parse-edn-str "truefalse"))
  (equal 'true. (clj-parse-edn-str "true."))
  (equal '/ (clj-parse-edn-str "/"))
  (should (equal '.true (clj-parse-edn-str ".true")))
  (should (equal 'some:sort:of:symbol (clj-parse-edn-str "some:sort:of:symbol")))
  (equal 'foo-bar (clj-parse-edn-str "foo-bar"))
  (should (equal '+some-symbol (clj-parse-edn-str "+some-symbol")))
  (should (equal '-symbol (clj-parse-edn-str "-symbol"))))

(ert-deftest booleans ()
  :tags '(edn boolean)
  (should (equal t (clj-parse-edn-str "true")))
  (should (equal nil (clj-parse-edn-str "false "))))

(ert-deftest characters ()
  :tags '(edn characters)
  (should (equal 97 (clj-parse-edn-str "\\a")))
  (should (equal 960 (clj-parse-edn-str "\\u03C0")))
  ;;(should (equal 'newline (clj-parse-edn-str "\\newline")))
  )

(ert-deftest elision ()
  :tags '(edn elision)
  (should-not (clj-parse-edn-str "#_foo"))
  (should-not (clj-parse-edn-str "#_ 123"))
  (should-not (clj-parse-edn-str "#_:foo"))
  (should-not (clj-parse-edn-str "#_ \\a"))
  (should-not (clj-parse-edn-str "#_
\"foo\""))
  (should-not (clj-parse-edn-str "#_ (1 2 3)"))
  (should (equal '(1 3) (clj-parse-edn-str "(1 #_ 2 3)")))
  (should (equal '[1 2 3 4] (clj-parse-edn-str "[1 2 #_[4 5 6] 3 4]")))
  (should (map-equal (make-seeded-hash-table :foo :bar)
                     (clj-parse-edn-str "{:foo #_elided :bar}")))
  (should (equal (edn-list-to-set '(1 2 3 4))
                 (clj-parse-edn-str "#{1 2 #_[1 2 3] 3 #_ (1 2) 4}")))
  (should (equal [a d] (clj-parse-edn-str "[a #_ ;we are discarding what comes next
 c d]"))))

(ert-deftest string ()
  :tags '(edn string)
  (should (equal "this is a string" (clj-parse-edn-str "\"this is a string\"")))
  (should (equal "this has an escaped \"quote in it"
                 (clj-parse-edn-str "\"this has an escaped \\\"quote in it\"")))
  (should (equal "foo\tbar" (clj-parse-edn-str "\"foo\\tbar\"")))
  (should (equal "foo\nbar" (clj-parse-edn-str "\"foo\\nbar\"")))
  (should (equal "this is a string \\ that has an escaped backslash"
                 (clj-parse-edn-str "\"this is a string \\\\ that has an escaped backslash\"")))
  (should (equal "[" (clj-parse-edn-str "\"[\""))))

(ert-deftest keywords ()
  :tags '(edn keywords)
  (should (equal :namespace\.of\.some\.length/keyword-name
                 (clj-parse-edn-str ":namespace.of.some.length/keyword-name")))
  (should (equal :\#/\# (clj-parse-edn-str ":#/#")))
  (should (equal :\#/:a (clj-parse-edn-str ":#/:a")))
  (should (equal :\#foo (clj-parse-edn-str ":#foo"))))

(ert-deftest integers ()
  :tags '(edn integers)
  (should (= 0 (clj-parse-edn-str "0")))
  (should (= 0 (clj-parse-edn-str "+0")))
  (should (= 0 (clj-parse-edn-str "-0")))
  (should (= 100 (clj-parse-edn-str "100")))
  (should (= -100 (clj-parse-edn-str "-100"))))

(ert-deftest floats ()
  :tags '(edn floats)
  (should (= 12.32 (clj-parse-edn-str "12.32")))
  (should (= -12.32 (clj-parse-edn-str "-12.32")))
  (should (= 9923.23 (clj-parse-edn-str "+9923.23")))
  (should (= 4.5e+044 (clj-parse-edn-str "45e+43")))
  (should (= -4.5e-042 (clj-parse-edn-str "-45e-43")))
  (should (= 4.5e+044 (clj-parse-edn-str "45E+43"))))

(ert-deftest lists ()
  :tags '(edn lists)
  (should-not (clj-parse-edn-str "()"))
  (should (equal '(1 2 3) (clj-parse-edn-str "( 1 2 3)")))
  (should (equal '(12.1 ?a foo :bar) (clj-parse-edn-str "(12.1 \\a foo :bar)")))
  (should (equal '((:foo bar :bar 12)) (clj-parse-edn-str "( (:foo bar :bar 12))")))
  (should (equal
           '(defproject com\.thortech/data\.edn "0.1.0-SNAPSHOT")
           (clj-parse-edn-str "(defproject com.thortech/data.edn \"0.1.0-SNAPSHOT\")"))))

(ert-deftest vectors ()
  :tags '(edn vectors)
  (should (equal [] (clj-parse-edn-str "[]")))
  (should (equal [] (clj-parse-edn-str "[ ]")))
  (should (equal '[1 2 3] (clj-parse-edn-str "[ 1 2 3 ]")))
  (should (equal '[12.1 ?a foo :bar] (clj-parse-edn-str "[ 12.1 \\a foo :bar]")))
  (should (equal '[[:foo bar :bar 12]] (clj-parse-edn-str "[[:foo bar :bar 12]]")))
  (should (equal '[( :foo bar :bar 12 ) "foo"]
                 (clj-parse-edn-str "[(:foo bar :bar 12) \"foo\"]")))
  (should (equal '[/ \. * ! _ \? $ % & = - +]
                 (clj-parse-edn-str "[/ . * ! _ ? $ % & = - +]")))
  (should (equal
           ;;[99 newline return space tab]
           [99 10 13 32 9]
           (clj-parse-edn-str "[\\c \\newline \\return \\space \\tab]"))))

(defun map-equal (m1 m2)
  (and (and (hash-table-p m1) (hash-table-p m2))
       (eq (hash-table-test m1) (hash-table-test m2))
       (= (hash-table-count m1) (hash-table-count m2))
       (equal (hash-table-keys m1) (hash-table-keys m2))
       (equal (hash-table-values m1) (hash-table-values m2))))

(defun make-seeded-hash-table (&rest keys-and-values)
  (let ((m (make-hash-table :test #'equal)))
    (while keys-and-values
      (puthash (pop keys-and-values) (pop keys-and-values) m))
    m))

(ert-deftest maps ()
  :tags '(edn maps)
  (should (hash-table-p (clj-parse-edn-str "{ }")))
  (should (hash-table-p (clj-parse-edn-str "{}")))
  (should (map-equal (make-seeded-hash-table :foo :bar :baz :qux)
                     (clj-parse-edn-str "{ :foo :bar :baz :qux}")))
  (should (map-equal (make-seeded-hash-table 1 "123" 'vector [1 2 3])
                     (clj-parse-edn-str "{ 1 \"123\" vector [1 2 3]}")))
  (should (map-equal (make-seeded-hash-table [1 2 3] "some numbers")
                     (clj-parse-edn-str "{[1 2 3] \"some numbers\"}"))))

(ert-deftest sets ()
  :tags '(edn sets)
  (should (edn-set-p (clj-parse-edn-str "#{}")))
  (should (edn-set-p (clj-parse-edn-str "#{ }")))
  (should (equal (edn-list-to-set '(1 2 3)) (clj-parse-edn-str "#{1 2 3}")))
  (should (equal (edn-list-to-set '(1 [1 2 3] 3)) (clj-parse-edn-str "#{1 [1 2 3] 3}"))))

(ert-deftest comment ()
  :tags '(edn comments)
  (should-not (clj-parse-edn-str ";nada"))
  (should (equal 1 (clj-parse-edn-str ";; comment
1")))
  (should (equal [1 2 3] (clj-parse-edn-str "[1 2 ;comment to eol
3]")))
  (should (equal '[valid more items] (clj-parse-edn-str "[valid;touching trailing comment
 more items]")))
  (should (equal [valid vector more vector items] (clj-parse-edn-str "[valid vector
 ;;comment in vector
 more vector items]"))))

(defun test-val-passed-to-handler (val)
  (should (listp val))
  (should (= (length val) 2))
  (should (= 1 (car val)))
  1)

(setq clj-edn-test-extra-handlers
      (a-list
       'my/type #'test-val-passed-to-handler
       'my/other-type (lambda (val) 2)))

(ert-deftest tags ()
  :tags '(edn tags)
  (should-error (clj-parse-edn-str "#my/type value" clj-edn-test-extra-handlers))
  (should (= 1 (clj-parse-edn-str "#my/type (1 2)" clj-edn-test-extra-handlers)))
  (should (= 2 (clj-parse-edn-str "#my/other-type {:foo :bar}" clj-edn-test-extra-handlers))))

(ert-deftest roundtrip ()
  :tags '(edn roundtrip)
  (let ((data [1 2 3 :foo (4 5) qux "quux"]))
    (should (equal data (clj-parse-edn-str (edn-print-string data))))
    (should (map-equal (make-seeded-hash-table :foo :bar)
                       (clj-parse-edn-str (edn-print-string (make-seeded-hash-table :foo :bar)))))
    (should (equal (edn-list-to-set '(1 2 3 [3 1.11]))
                   (clj-parse-edn-str (edn-print-string (edn-list-to-set '(1 2 3 [3 1.11]))))))
    (should-error (clj-parse-edn-str "#myapp/Person {:first \"Fred\" :last \"Mertz\"}"))))

(ert-deftest inst ()
  :tags '(edn inst)
  (let* ((inst-str "#inst \"1985-04-12T23:20:50.52Z\"")
         (inst (clj-parse-edn-str inst-str))
         (time (date-to-time "1985-04-12T23:20:50.52Z")))
    (should (edn-inst-p inst))
    (should (equal time (edn-inst-to-time inst)))))

(ert-deftest uuid ()
  :tags '(edn uuid)
  (let* ((str "f81d4fae-7dec-11d0-a765-00a0c91e6bf6")
         (uuid (clj-parse-edn-str (concat "#uuid \"" str "\""))))
    (should (edn-uuid-p uuid))))

;; (ert-deftest invalid-edn ()
;;   (should-error (clj-parse-edn-str "///"))
;;   (should-error (clj-parse-edn-str "~cat"))
;;   (should-error (clj-parse-edn-str "foo/bar/baz/qux/quux"))
;;   (should-error (clj-parse-edn-str "#foo/"))
;;   (should-error (clj-parse-edn-str "foo/"))
;;   (should-error (clj-parse-edn-str ":foo/"))
;;   (should-error (clj-parse-edn-str "#/foo"))
;;   (should-error (clj-parse-edn-str "/symbol"))
;;   (should-error (clj-parse-edn-str ":/foo"))
;;   (should-error (clj-parse-edn-str "+5symbol"))
;;   (should-error (clj-parse-edn-str ".\\newline"))
;;   (should-error (clj-parse-edn-str "0cat"))
;;   (should-error (clj-parse-edn-str "-4cats"))
;;   (should-error (clj-parse-edn-str ".9"))
;;   (should-error (clj-parse-edn-str ":keyword/with/too/many/slashes"))
;;   (should-error (clj-parse-edn-str ":a.b.c/"))
;;   (should-error (clj-parse-edn-str "\\itstoolong"))
;;   (should-error (clj-parse-edn-str ":#/:"))
;;   (should-error (clj-parse-edn-str "/foo//"))
;;   (should-error (clj-parse-edn-str "///foo"))
;;   (should-error (clj-parse-edn-str ":{}"))
;;   (should-error (clj-parse-edn-str "//"))
;;   (should-error (clj-parse-edn-str "##"))
;;   (should-error (clj-parse-edn-str "::"))
;;   (should-error (clj-parse-edn-str "::a"))
;;   (should-error (clj-parse-edn-str ".5symbol"))
;;   (should-error (clj-parse-edn-str "{ \"foo\""))
;;   (should-error (clj-parse-edn-str "{ \"foo\" :bar"))
;;   (should-error (clj-parse-edn-str "{"))
;;   (should-error (clj-parse-edn-str ":{"))
;;   (should-error (clj-parse-edn-str "{{"))
;;   (should-error (clj-parse-edn-str "}"))
;;   (should-error (clj-parse-edn-str ":}"))
;;   (should-error (clj-parse-edn-str "}}"))
;;   (should-error (clj-parse-edn-str "#:foo"))
;;   (should-error (clj-parse-edn-str "\\newline."))
;;   (should-error (clj-parse-edn-str "\\newline0.1"))
;;   (should-error (clj-parse-edn-str "^"))
;;   (should-error (clj-parse-edn-str ":^"))
;;   (should-error (clj-parse-edn-str "_:^"))
;;   (should-error (clj-parse-edn-str "#{{[}}"))
;;   (should-error (clj-parse-edn-str "[}"))
;;   (should-error (clj-parse-edn-str "@cat")))

;;; edn-el-test-suite.el ends here
