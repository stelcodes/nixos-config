#!/usr/bin/env bb

(require '[babashka.process :as p])
(require '[cheshire.core :as json])
(require '[clojure.pprint :as pp])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(defn get-pm-node []
  (letfn [(get-sway-tree []
            (-> (p/sh ["swaymsg" "-t" "get_tree"])
                :out
                (json/parse-string true)))
          (find-node [{:keys [nodes floating_nodes] :as node}]
            (if (= "org.keepassxc.KeePassXC" (:app_id node))
              node
              (some find-node (into nodes floating_nodes))))]
    (find-node (get-sway-tree))))

(defn set-pm-defaults []
  (p/sh ["swaymsg" "for_window [app_id=org.keepassxc.KeePassXC] floating enable; for_window [app_id=org.keepassxc.KeePassXC] resize set width 80 ppt height 90 ppt; for_window [app_id=org.keepassxc.KeePassXC] move position center"]))

(defn start-pm []
  (p/process ["swaymsg" "exec keepassxc"]))

(defn focus-pm []
  (p/sh ["swaymsg" "[app_id=org.keepassxc.KeePassXC] focus, move window to workspace current, floating enable, resize set width 80 ppt height 90 ppt, move position center"]))

(defn hide-pm []
  (p/sh ["swaymsg" "[app_id=org.keepassxc.KeePassXC] move scratchpad"]))

(set-pm-defaults)

(if-let [pm-node (get-pm-node)]
  (if (:focused pm-node)
    (hide-pm)
    (focus-pm))
  (start-pm))
