/* Copyright (C) 2022 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
package github.koukobin.ermis.client.main.java.controllers.entry;

import java.io.IOException;
import java.math.RoundingMode;
import java.net.URL;
import java.text.DecimalFormat;
import java.util.EnumMap;
import java.util.List;
import java.util.ResourceBundle;

import github.koukobin.ermis.client.main.java.info.entry.EntryInfo;
import github.koukobin.ermis.client.main.java.service.client.io_client.Client;
import github.koukobin.ermis.client.main.java.util.MemoryUtil;
import github.koukobin.ermis.client.main.java.util.UITransitions;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.EntryType;

import com.jfoenix.controls.JFXButton;

import io.github.palexdev.materialfx.controls.MFXProgressBar;
import javafx.animation.Interpolator;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.StackPane;
import javafx.util.Duration;
import me.gosimple.nbvcxz.Nbvcxz;
import me.gosimple.nbvcxz.resources.Configuration;
import me.gosimple.nbvcxz.resources.ConfigurationBuilder;
import me.gosimple.nbvcxz.resources.Dictionary;
import me.gosimple.nbvcxz.resources.DictionaryBuilder;
import me.gosimple.nbvcxz.scoring.Result;

/**
 * @author Ilias Koukovinis
 * 
 */
public final class CreateAccountSceneController extends GeneralEntryController {

	@FXML
	private TextField usernameTextField;
	
	@FXML
	private AnchorPane root;
	@FXML
	private JFXButton switchToLoginSceneButton;

	@FXML
	private MFXProgressBar passwordQualityBar;
	@FXML
	private Label passwordQualityLabel;
	@FXML
	private Label entropyLabel;
	
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		registrationType = EntryType.CREATE_ACCOUNT;
		
		ChangeListener<String> listenerToCalculatePasswordStrength = new ChangeListener<String>() {

			private static final Nbvcxz nbvcxz;
			
			static {
				// Create a map of excluded words on a per-user basis using a hypothetical "User" object that contains this info
				List<Dictionary> dictionaryList = ConfigurationBuilder.getDefaultDictionaries();
				dictionaryList.add(new DictionaryBuilder()
				        .setDictionaryName("exclude")
				        .setExclusion(true)
				        .createDictionary());

				// Create our configuration object and set our custom dictionary list
				Configuration configuration = new ConfigurationBuilder()
				        .setDictionaries(dictionaryList)
				        .createConfiguration();
				        
				// Create our Nbvcxz object with the configuration we built
				nbvcxz = new Nbvcxz(configuration);
			}
			
			@Override
			public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
				
				Result result = nbvcxz.estimate(newValue);
				double entropy = result.getEntropy();
				
				double progress;
				
				if (entropy < 100) {
					progress = entropy / 100;
				} else {
					progress = 1.0;
				}

				passwordQualityBar.setProgress(progress);
				
				// Round entropy before displaying
				DecimalFormat df = new DecimalFormat("#.##");
				df.setRoundingMode(RoundingMode.HALF_EVEN);
				String entropyRounded = df.format(entropy + 1e-6);
				entropyLabel.setText(entropyRounded + " bit");
				
				if (entropy < 40.0) {
					passwordQualityLabel.setText("Poor");
				} else if (entropy < 65) {
					passwordQualityLabel.setText("Weak");
				} else if (entropy < 100) {
					passwordQualityLabel.setText("Good");
				} else {
					passwordQualityLabel.setText("Excellent");
				}
			}
		};
		
		passwordFieldTextHidden.textProperty().addListener(listenerToCalculatePasswordStrength);
		passwordFieldTextVisible.textProperty().addListener(listenerToCalculatePasswordStrength);
	}

	@Override
	public void switchScene(ActionEvent event) throws IOException {

		FXMLLoader loader = new FXMLLoader(EntryInfo.Login.FXML_LOCATION);
		final Parent loginRoot = loader.load();

		LoginSceneController loginSceneController = loader.getController();
		loginSceneController.setFXMLLoader(this.originalFXMLLoader);
		this.originalFXMLLoader.setController(loginSceneController);
		
		Scene scene = switchToLoginSceneButton.getScene();
		switchToLoginSceneButton.setDisable(true);

		scene.getStylesheets().add(EntryInfo.Login.CSS_LOCATION);

		Runnable transition = UITransitions.newBuilder()
				.setDirection(UITransitions.Direction.YAxis.BOTTOM_TO_TOP)
				.setDuration(Duration.seconds(1))
				.setInterpolator(Interpolator.EASE_OUT)
				.setNewComponent(loginRoot)
				.setOldComponent(this.root)
				.setParentContainer((StackPane) scene.getRoot())
				.build();

		transition.run();
	}

	@Override
	public void register(ActionEvent event) throws IOException {
		Client.CreateAccountEntry clientEntry = Client.createNewCreateAccountEntry();
		clientEntry.sendEntryType();

		EnumMap<CreateAccountInfo.Credential, String> accountCredentials = new EnumMap<>(CreateAccountInfo.Credential.class);
		accountCredentials.put(CreateAccountInfo.Credential.EMAIL, getEmail());
		accountCredentials.put(CreateAccountInfo.Credential.USERNAME, getUsername());
		accountCredentials.put(CreateAccountInfo.Credential.PASSWORD, getPassword());

		boolean isSuccessful = sendAndValidateCredentials(clientEntry, accountCredentials);

		// Clear sensitive data from memory
		MemoryUtil.freeStringFromMemory(accountCredentials.get(CreateAccountInfo.Credential.PASSWORD));

		if (!isSuccessful) {
			return;
		}

		isSuccessful = performVerification(accountCredentials.get(CreateAccountInfo.Credential.EMAIL), clientEntry);

		if (!isSuccessful) {
			return;
		}

		closeEntry(event);
	}

	public String getUsername() {
		return usernameTextField.getText();
	}

}


