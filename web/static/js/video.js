import Player from "./player"

let Video = {
	init(socket, element) {
		if(!element) { return }
		let playerId = element.getAttribute("data-player-id")
		let videoId = element.getAttribute("data-id")
		// start connection
		socket.connect()
		Player.init(element.id, playerId, () => {
			// when player is ready
			console.log("calling Video.onReady")
			this.onReady(videoId, socket)
		})
	},
	onReady(videoId, socket) {
		let msgContainer = document.getElementById("msg-container")
		let msgInput = document.getElementById("msg-input")
		let postButton = document.getElementById("msg-submit")
		let vidChannel = socket.channel("videos:" + videoId)

		postButton.addEventListener("click", e => {
			// build payload object
			// you're calling a function, in JS
			let payload = {body: msgInput.value, at: Player.getCurrentTime()}
			// this sync operation makes socket send payload to back-end
			vidChannel.push("new_annotation", payload)
				// in case of error
				.receive("error", e => console.log(e))
			msgInput.value = ""
		})

		// catch broadcase message "new_annotation"
		vidChannel.on("new_annotation", (resp) => {
			// add last_seen_id, server only sends the data missed by client
			// channel.params: being sent to the server on every channel.join
			vidChannel.params.last_seen_id = resp.id
			this.renderAnnotation(msgContainer, resp)
		})	

		vidChannel.on("ping", ({count}) => console.log("PING:", count))

		msgContainer.addEventListener("click", e => {
			e.preventDefault()
			let seconds = e.target.getAttribute("data-seek")
			if (!seconds) { return }

		  Player.seekTo(seconds)
		})

		vidChannel.join()
		  // handle both paths (happy and sad)
			.receive("ok", resp => {
				let ids = resp.annotations.map(ann => ann.id)
				if (ids.length > 0) { vidChannel.params.last_seen_id = Math.max(...ids) }
				this.scheduleMessages(msgContainer, resp.annotations)
			})
			.receive("error", reason => console.log("join failed: ", resp))
	},

	esc(str) {
		let div = document.createElement("div")
		div.appendChild(document.createTextNode(str))
		return div.innerHTML
	},

	renderAnnotation(msgContainer, {user, body, at}) {
		let template = document.createElement("div")
		template.innerHTML = `
			<a href="#" data-seek="${this.esc(at)}">
				[${this.formatTime(at)}]
				<b>${this.esc(user.username)}: </b> ${this.esc(body)}
			</a>
		`
		msgContainer.appendChild(template)
		msgContainer.scrollTop = msgContainer.scrollHeight
	},

	scheduleMessages(msgContainer, annotations) {
		setTimeout(() => {
			let ctime = Player.getCurrentTime()
			let remaining = this.renderAtTime(annotations, ctime, msgContainer)
			this.scheduleMessages(msgContainer, remaining)
		}, 1000)
	},

	renderAtTime(annotations, seconds, msgContainer) {
		return annotations.filter(ann => {
			if(ann.at > seconds) {
				return true
			} else {
				this.renderAnnotation(msgContainer, ann)
			  return false;
			}
		})
	},

	formatTime(at) {
		let date = new Date(null)
		date.setSeconds(at / 1000)
		return date.toISOString().substr(14, 5)
	}
}


export default Video
