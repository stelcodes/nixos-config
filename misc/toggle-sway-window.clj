#!/usr/bin/env bb

(require '[babashka.cli :as cli])
(require '[babashka.process :as p])
(require '[cheshire.core :as json])
(require '[clojure.pprint :as pp])
(require '[clojure.string :as str])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(def cli-opts
  {:require [:id]
   :exec-args {:floating true
               :kill false
               :width nil
               :height nil}
   :validate {:id string?
              :floating boolean?
              :kill boolean?
              :width (some-fn nil? pos?)
              :height (some-fn nil? pos?)}})

(def cli-results (cli/parse-args *command-line-args* cli-opts))

(def opts (:opts cli-results))

(def args (:args cli-results))

(defn make-resize-str []
  (let [{:keys [width height]} opts]
    (when (or width height)
      (str "resize set" (when width (str " width " width " ppt ")) (when height (str " height " height " ppt ")) ", "))))

(def position-cmds (str "floating "
                        (if-not (:floating opts)
                          "disable"
                          (str "enable, " (make-resize-str) "move position center"))))

(def criteria (str "[app_id=" (:id opts) "]"))

(defn get-node []
  (letfn [(get-sway-tree []
            (-> (p/sh ["swaymsg" "-t" "get_tree"])
                :out
                (json/parse-string true)))
          (find-node [{:keys [nodes floating_nodes] :as node}]
            (if (= (:id opts) (:app_id node))
              node
              (some find-node (into nodes floating_nodes))))]
    (find-node (get-sway-tree))))

(defn set-defaults []
  (p/sh ["swaymsg" (str "for_window " criteria " " position-cmds)]))

(defn start []
  (p/process ["swaymsg" (str/join " " (cons "exec" args))]))

(defn focus []
  (p/sh ["swaymsg" (str criteria " focus, move window to workspace current, " position-cmds)]))

(defn hide []
  (p/sh ["swaymsg" (str criteria (if (:kill opts) " kill" " move scratchpad"))]))

;; Main program

(debug *command-line-args*)

(debug cli-results)

(if-let [node (get-node)]
  (if (:focused node)
    (hide)
    (focus))
  (start))
