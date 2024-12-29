/* Copyright (C) 2023 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.client.main.java.util;

import com.google.common.base.Preconditions;

import javafx.animation.Interpolator;
import javafx.animation.KeyFrame;
import javafx.animation.KeyValue;
import javafx.animation.Timeline;
import javafx.beans.property.DoubleProperty;
import javafx.scene.Node;
import javafx.scene.layout.StackPane;
import javafx.util.Duration;

/**
 * This class facilitates smooth transitions between various components in the user interface,
 * providing a customizable and reusable way to manage animations and directional transitions.
 * 
 * @author Ilias Koukovinis
 *
 */
public final class UITransitions {

	private UITransitions() {}
	
	public static class Direction {
		
		private interface Axis {}
		
		public enum XAxis implements Axis {
			LEFT_TO_RIGHT,
			RIGHT_TO_LEFT;
		}
		
		public enum YAxis implements Axis {
			TOP_TO_BOTTOM,
			BOTTOM_TO_TOP;
		}
		
		public enum Which {
			OLD, NEW;
		}
	}
	
	public static UITransitionBuilder newBuilder() {
		return new UITransitionBuilder();
	}
	
	public static final class UITransitionBuilder {
		
		private StackPane parentContainer;
		private Node newComponent;
		private Node oldComponent;
		
		private Interpolator interpolator;
		private Duration duration;
		private Direction.Axis direction;
		
		private Direction.Which which = Direction.Which.NEW;

		private UITransitionBuilder() {}

		public UITransitionBuilder setParentContainer(StackPane parentContainer) {
			this.parentContainer = parentContainer;
			return this;
		}

		public UITransitionBuilder setNewComponent(Node newComponent) {
			this.newComponent = newComponent;
			return this;
		}

		public UITransitionBuilder setOldComponent(Node oldComponent) {
			if (oldComponent.equals(newComponent)) {
				throw new IllegalArgumentException("Old component cannot be the same as the new component");
			}

			this.oldComponent = oldComponent;
			return this;
		}

		public UITransitionBuilder setInterpolator(Interpolator interpolator) {
			this.interpolator = interpolator;
			return this;
		}

		public UITransitionBuilder setDuration(Duration duration) {
			this.duration = duration;
			return this;
		}

		public UITransitionBuilder setDirection(Direction.Axis direction) {
			this.direction = direction;
			return this;
		}
		
		public UITransitionBuilder setWhich(Direction.Which which) {
			this.which = which;
			return this;
		}

		public Runnable build() {
			
			Preconditions.checkNotNull(newComponent, "newComponent cannot be null");
			Preconditions.checkNotNull(oldComponent, "oldComponent cannot be null");
			Preconditions.checkNotNull(interpolator, "interpolator cannot be null");
			Preconditions.checkNotNull(duration, "duration cannot be null");
			Preconditions.checkNotNull(direction, "direction cannot be null");
			
			return () -> {
				
				DoubleProperty property;

				switch (which) {
				case NEW -> {
					if (direction instanceof Direction.XAxis) {
						property = newComponent.translateXProperty();
						property.set(parentContainer.getWidth());
					} else {
						property = newComponent.translateYProperty();
						property.set(parentContainer.getHeight());
					}

					// Invert position of axis property in the following cases
					if (direction == Direction.XAxis.LEFT_TO_RIGHT || direction == Direction.YAxis.TOP_TO_BOTTOM) {
						property.set(property.getValue() * -1);
					}

					parentContainer.getChildren().add(newComponent);

					Timeline timeline = new Timeline();
					KeyValue kv = new KeyValue(property, 0, interpolator);
					KeyFrame kf = new KeyFrame(duration, kv);

//					KeyValue kv2 = new KeyValue(oldComponent.translateXProperty(), property.getValue() * -1, interpolator);
//					KeyFrame kf2 = new KeyFrame(duration, kv2);
//					
//					KeyValue kv3 = new KeyValue(oldComponent.opacityProperty(), 0, interpolator);
//					KeyFrame kf3 = new KeyFrame(duration, kv3);
					
					timeline.getKeyFrames().add(kf);
//					timeline.getKeyFrames().add(kf2);
//					timeline.getKeyFrames().add(kf3);

					// remove create account scene
					timeline.setOnFinished(event2 -> parentContainer.getChildren().remove(oldComponent));
					timeline.play();
				}
				case OLD -> {
				
					if (direction instanceof Direction.XAxis) {
						property = oldComponent.translateXProperty();
					} else {
						property = oldComponent.translateYProperty();
					}

					parentContainer.getChildren().add(newComponent);
					newComponent.toBack();

					Timeline timeline = new Timeline();
					KeyValue kv = new KeyValue(property, parentContainer.getWidth(), interpolator);
					KeyFrame kf = new KeyFrame(duration, kv);

					timeline.getKeyFrames().add(kf);

					// remove create account scene
					timeline.setOnFinished(event2 -> parentContainer.getChildren().remove(oldComponent));
					timeline.play();
				}
				default -> throw new UnsupportedOperationException("Operation not implemented: " + which);
				}
			};
		}
	}
}

