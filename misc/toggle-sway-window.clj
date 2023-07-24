#!/usr/bin/env bb

(require '[babashka.process :as p])
(require '[cheshire.core :as json])
(require '[clojure.pprint :as pp])
(require '[babashka.cli :as cli])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(def cli-opts
  {:require [:id :cmd]
   :exec-args {:floating true
               :width 80
               :height 90}
   :validate {:id string?
              :cmd string?
              :floating boolean?
              :width pos?
              :height pos?}})

(def opts (:opts (cli/parse-args *command-line-args* cli-opts)))

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

(def position-cmds (str "floating "
                        (if-not (:floating opts)
                          "disable"
                          (str "enable, resize set width " (:width opts) " ppt height " (:height opts) " ppt, move position center"))))

(def criteria (str "[app_id=" (:id opts) "]"))

(defn set-defaults []
  (p/sh ["swaymsg" (str "for_window " criteria " " position-cmds)]))

(defn start []
  (p/process ["swaymsg" (str "exec " (:cmd opts))]))

(defn focus []
  (p/sh ["swaymsg" (str criteria " focus, move window to workspace current, " position-cmds)]))

(defn hide []
  (p/sh ["swaymsg" (str criteria " move scratchpad")]))

;; Main program

(debug opts)

(set-defaults)

(if-let [node (get-node)]
  (if (:focused node)
    (hide)
    (focus))
  (start))
