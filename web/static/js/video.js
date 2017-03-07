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
		let mgsInput = document.getElementById("msg-input")
		let postButton = document.getElementById("msg-submit")
		let vidChannel = socket.channel("videos:" + videoId)

		vidChannel.join()
		  // handle both paths (happy and sad)
			.receive("ok",resp => console.log("accepted: ", resp))
			.receive("error",resp => console.log("denied: ", resp))
	}
}

export default Video
