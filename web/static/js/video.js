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
			let payload = {body: msgInput.value, at: Player.getCurrentTime}
			// this sync operation makes socket send payload to back-end
			vidChannel.push("new_annotation", payload)
				// in case of error
				.receive("error", e => console.log(e))
			msgInput.value = ""
		})

		// catch broadcase message "new_annotation"
		vidChannel.on("new_annotation", (resp) => {
			this.renderAnnotation(msgContainer, resp)
		})	

		vidChannel.on("ping", ({count}) => console.log("PING:", count))
		vidChannel.join()
		  // handle both paths (happy and sad)
			.receive("ok", resp => console.log("joined channel ", resp))
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
				<b>${this.esc(user.username)}: </b> ${this.esc(body)}
			</a>
		`
		msgContainer.appendChild(template)
		msgContainer.scrollTop = msgContainer.scrollHeight
	}
}


export default Video
