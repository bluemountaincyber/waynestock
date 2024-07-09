import React, {Component} from "react";
import {
    Confirm
} from "semantic-ui-react";

export default class Modal extends Component {
    state = { open: true }

    show = () => {
        this.setState({ open: true })
    }
    handleConfirm = () => {
        this.setState({ open: false })
    }
    handleCancel = () => this.setState({ open: false })

  render() {
    return (
      <div>
        <Confirm
          open={this.state.open}
          content="We've had some word that there is some bad red rope licorice circulating in the area and it will be banned at this festival. Please stay away from the red rope licorice. Do not bite any off or chew it. It could cause a dental emergency."
          onCancel={this.handleCancel}
          onConfirm={this.handleConfirm}
        />
      </div>
    )
  }
}